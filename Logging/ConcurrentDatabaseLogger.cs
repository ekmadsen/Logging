using System;
using System.Data.Common;
using System.Threading.Tasks;
using Dapper;
using ErikTheCoder.Logging.Settings;
using JetBrains.Annotations;


namespace ErikTheCoder.Logging
{
    [UsedImplicitly]
    public class ConcurrentDatabaseLogger : ConcurrentLoggerBase
    {
        private const int _connectionTimeoutSec = 5;
        private const string _sqlGetHostId = "select id from logging.hosts where name = @hostname";
        private const string _sqlInsertHost = "insert into logging.hosts (name) output inserted.id values (@hostname)";
        private const string _sqlGetAppId = "select id from logging.apps where name = @appname";
        private const string _sqlInsertApp = "insert into logging.apps (name) output inserted.id values (@appname)";
        private const string _sqlGetProcessId = "select p.id from logging.processes p inner join logging.apps a on p.appid = a.id where a.id = @appid and p.name = @processname";
        private const string _sqlInsertProcess = "insert into logging.processes (appid, name) output inserted.id values (@appid, @processName)";
        private const string _sqlInsertTraceLogs = "insert into logging.tracelogs (hostId, processId, timestamp, correlationid, levelid, message) " +
            "values (@hostId, @processId, @timestamp, @correlationid, @loglevel, @message)";
        private const string _sqlInsertPerformanceLogs = "insert into logging.performancelogs (hostId, processId, timestamp, correlationid, operationname, operationduration) " +
            "values (@hostId, @processId, @timestamp, @correlationid, @operationname, @operationduration)";
        private const string _sqlInsertMetricLogs = "insert into logging.metriclogs (hostId, processId, timestamp, correlationid, itemid, metricname, datetimevalue, intvalue, textvalue) " +
            "values (@hostId, @processId, @timestamp, @correlationid, @itemid, @metricname, @datetimevalue, @intvalue, @textvalue)";
        private readonly string _connection;
        private readonly IDatabase _database;
        private readonly int? _hostId;
        private readonly int? _processId;


        public ConcurrentDatabaseLogger(DatabaseLoggerSettings Settings, IDatabase Database) : base(Settings)
        {
            if (!string.IsNullOrEmpty(Settings.Connection) && (Settings.Connection.IndexOf("Connection Timeout", StringComparison.CurrentCultureIgnoreCase) < 0))
            {
                // Append timeout to connection string.
                _connection = $"{Settings.Connection};Connection Timeout={_connectionTimeoutSec}";
            }
            else _connection = Settings.Connection;
            _database = Database;
            try
            {
                _hostId = RegisterHost(Environment.MachineName);
            }
            catch (Exception exception)
            {
                Exception newException = new Exception("Failed to register logging host.  Logging disabled.", exception);
                WriteCriticalError(newException);
                return;
            }
            try
            {
                _processId = RegisterProcess(Settings.AppName, Settings.ProcessName);
            }
            catch (Exception exception)
            {
                Exception newException = new Exception("Failed to register logging process.  Logging disabled.", exception);
                WriteCriticalError(newException);
            }
        }


        protected override async Task WriteLogAsync(TraceLog Log)
        {
            if (_hostId.HasValue && _processId.HasValue && !string.IsNullOrWhiteSpace(Log.Message))
            {
                using (DbConnection connection = await _database.OpenConnectionAsync(_connection))
                {
                    var queryParameters = new
                    {
                        HostId = _hostId.Value,
                        ProcessId = _processId.Value,
                        Log.Timestamp,
                        CorrelationId = Log.CorrelationId.ToString().ToUpper(),
                        Log.LogLevel,
                        Log.Message
                    };
                    await connection.ExecuteAsync((_sqlInsertTraceLogs), queryParameters);
                }
            }
        }


        protected override async Task WriteLogAsync(PerformanceLog Log)
        {
            if (_hostId.HasValue && _processId.HasValue)
            {
                using (DbConnection connection = await _database.OpenConnectionAsync(_connection))
                {
                    var queryParameters = new
                    {
                        HostId = _hostId.Value,
                        ProcessId = _processId.Value,
                        Log.Timestamp,
                        CorrelationId = Log.CorrelationId.ToString().ToUpper(),
                        Log.OperationName,
                        Log.OperationDuration
                    };
                    await connection.ExecuteAsync(_sqlInsertPerformanceLogs, queryParameters);
                }
            }
        }


        protected override async Task WriteLogAsync(MetricLog Log)
        {
            if (_hostId.HasValue && _processId.HasValue)
            {
                using (DbConnection connection = await _database.OpenConnectionAsync(_connection))
                {
                    var queryParameters = new
                    {
                        HostId = _hostId.Value,
                        ProcessId = _processId.Value,
                        Log.Timestamp,
                        CorrelationId = Log.CorrelationId.ToString().ToUpper(),
                        Log.ItemId,
                        Log.MetricName,
                        Log.DateTimeValue,
                        Log.IntValue,
                        Log.TextValue
                    };
                    await connection.ExecuteAsync(_sqlInsertMetricLogs, queryParameters);
                }
            }
        }


        // Method is not marked async because it's called from constructor (which can't be marked async).
        private int RegisterHost(string HostName)
        {
            using (DbConnection connection = _database.OpenConnectionAsync(_connection).Result)
            {
                // Get ID of existing host name or insert a new host name.
                var queryParameters = new { HostName };
                int? hostId = (int?)connection.ExecuteScalar(_sqlGetHostId, queryParameters) ?? (int)connection.ExecuteScalar(_sqlInsertHost, queryParameters);
                return hostId.Value;
            }
        }


        // Method is not marked async because it's called from constructor (which can't be marked async).
        private int RegisterProcess(string AppName, string ProcessName)
        {
            using (DbConnection connection = _database.OpenConnectionAsync(_connection).Result)
            {
                // Get ID of existing app or insert a new app.
                var appQueryParameters = new {AppName};
                int? appId = (int?)connection.ExecuteScalar(_sqlGetAppId, appQueryParameters) ?? (int)connection.ExecuteScalar(_sqlInsertApp, appQueryParameters);
                // Get ID of existing process or insert a new process.
                var processQueryParameters = new
                {
                    AppId = appId.Value,
                    ProcessName
                };
                int? processId = (int?)connection.ExecuteScalar(_sqlGetProcessId, processQueryParameters) ?? (int)connection.ExecuteScalar(_sqlInsertProcess, processQueryParameters);
                return processId.Value;
            }
        }
    }
}
