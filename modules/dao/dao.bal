import ballerinax/mysql;
import ballerina/sql;
import ballerinax/mysql.driver as _;
import TransactionCountingService.models;
import TransactionCountingService.utils;

public isolated class DAO {
    private final mysql:Client db;

    public function init(string host, string user, string password, string database, int port) returns error? {
        self.db = check new (host, user, password, database, port);
    }

    public isolated function insertTransactionRecords(models:TransactionRecord[] transactionRecords) returns sql:ExecutionResult[]|error {
        sql:ParameterizedQuery[] batch = from models:TransactionRecord tRecord in transactionRecords
                                         select `INSERT INTO TransactionRecords (host, serverID, serverType, count, recordedTime)
                                                VALUES (${tRecord.host}, ${tRecord.serverID}, ${tRecord.serverType}, ${tRecord.count}, ${tRecord.recordedTime});`;
        return check self.db->batchExecute(batch);
    }

    public isolated function getTransactionCount(models:dbQueryDTO? dbQuery) returns models:TransactionCountDTO|error {

        if (dbQuery == null) {
            return self.getTotalTransactionCount();
        }

        string serverID = dbQuery?.serverID.toString();
        string serverType = dbQuery?.serverType.toString();
        string startTime = dbQuery?.startTime.toString();
        string endTime = dbQuery?.endTime.toString();
        string host = dbQuery?.host.toString();

        if (serverID == "") {
            serverID = "%";
        }
        if (serverType == "") {
            serverType = "%";
        }
        if (host == "") {
            host = "%";
        }

        sql:ParameterizedQuery query;

        if (utils:isSqlTimestamp(startTime) && utils:isSqlTimestamp(endTime)) {
            query = `SELECT SUM(count) FROM TransactionRecords WHERE serverID LIKE ${serverID} AND serverType LIKE ${serverType} AND host LIKE ${host} AND recordedTime >= ${startTime} AND recordedTime <= ${endTime};`;
        } else if (utils:isSqlTimestamp(startTime) && !utils:isSqlTimestamp(endTime)) {
            query = `SELECT SUM(count) FROM TransactionRecords WHERE serverID LIKE ${serverID} AND serverType LIKE ${serverType} AND host LIKE ${host} AND recordedTime >= ${startTime}`;
        } else if (!utils:isSqlTimestamp(startTime) && utils:isSqlTimestamp(endTime)) {
            query = `SELECT SUM(count) FROM TransactionRecords WHERE serverID LIKE ${serverID} AND serverType LIKE ${serverType} AND host LIKE ${host} AND recordedTime <= ${endTime};`;
        } else {
            query = `SELECT SUM(count) FROM TransactionRecords WHERE serverID LIKE ${serverID} AND serverType LIKE ${serverType} AND host LIKE ${host};`;
        }

        decimal? result = check self.db->queryRow(query);
        models:TransactionCountDTO dto = {
            count: result
        };

        return dto;
    }

    public isolated function getTotalTransactionCount() returns models:TransactionCountDTO|sql:Error {
        sql:ParameterizedQuery query = `SELECT SUM(count) FROM TransactionRecords;`;
        decimal? result = check self.db->queryRow(query);
        models:TransactionCountDTO dto = {
            count: result
        };

        return dto;
    }
}


