namespace ErikTheCoder.Logging.Settings
{
    public class LoggerSettings : ILoggerSettings
    {
        public string AppName { get; set; }
        public string ProcessName { get; set; }
        public LogLevel TraceLogLevel { get; set; } = LogLevel.Debug;
        public bool EnablePerformanceLog { get; set; } = true;
        public bool EnableMetricLog { get; set; } = true;
        public bool SendTraceMessagesToConsole { get; set; }
        public int? MaxTraceLogSize { get; set; }
    }
}
