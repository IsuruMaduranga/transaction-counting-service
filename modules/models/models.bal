public type TransactionRecord record {
    readonly string id;
    string host;
    string serverID;
    string serverType;
    int count;
    string recordedTime;
};

public type DatabaseConfig record {|
    string host;
    int port;
    string user;
    string password;
    string database;
|};

public type ServerConfig record {|
    string certFile;
    string keyFile;
|};

public type dbQueryDTO record {|
    string? host?;
    string? serverID?;
    string? serverType?;
    string? startTime?;
    string? endTime?;
|};

public type TransactionCountDTO record {|
    decimal? count;
|};