import ballerina/regex;

public isolated function isSqlTimestamp(string time) returns boolean {
    string sqlTimestampPattern = "^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}$";
    return regex:matches(time, sqlTimestampPattern);
}
