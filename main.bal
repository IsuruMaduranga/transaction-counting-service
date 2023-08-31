import ballerina/http;
import ballerina/log;
import ballerina/sql;
import TransactionCountingService.models;
import TransactionCountingService.dao;

// Configurations
configurable models:DatabaseConfig databaseConfig = ?;
configurable models:ServerConfig serverConfig = ?;

listener http:Listener httpsListener = new (8080,
    secureSocket = {
        key: {
            certFile: serverConfig.certFile,
            keyFile: serverConfig.keyFile
        }
    }
);

@http:ServiceConfig { 
    auth: [
        {
            fileUserStoreConfig: {},
            scopes: ["read"]
        }
    ]
}

service /transactions on httpsListener {
    private final dao:DAO dao;

    function init() returns error? {
            self.dao = check new (
                databaseConfig.host,
                databaseConfig.user,
                databaseConfig.password,
                databaseConfig.database,
                databaseConfig.port
            );
    }

    resource isolated function get count() returns models:TransactionCountDTO|error {
        return check self.dao.getTotalTransactionCount();
    }

    resource isolated function post query/count(@http:Payload models:dbQueryDTO? dbQuery) returns models:TransactionCountDTO|error {
        return check self.dao.getTransactionCount(dbQuery);
    }

    @http:ResourceConfig {
        auth: [
            {
               fileUserStoreConfig: {},
               scopes: ["write"]
            }
       ]
    }
    resource isolated function post records(@http:Payload models:TransactionRecord[] transactionRecords) returns http:Response|error { 
        log:printInfo(transactionRecords.toJsonString()); 
        sql:ExecutionResult[] _ = check self.dao.insertTransactionRecords(transactionRecords);
        return new http:Response();
    }
}

