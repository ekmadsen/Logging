namespace ErikTheCoder.Logging.Settings
{
    public class LoggerSettings : ILoggerSettings
    {
        public string AppName { get; set; }
        public string ProcessName { get; set; }
        public LogLevel TraceLogLevel { get; set; }
        public bool EnablePerformanceLog { get; set; }
        public bool EnableMetricLog { get; set; }
        public bool SendTraceMessagesToConsole { get; set; }
        public int? MaxTraceLogSize { get; set; }
    }
}
