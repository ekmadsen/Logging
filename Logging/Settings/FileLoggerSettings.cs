using JetBrains.Annotations;


namespace ErikTheCoder.Logging.Settings
{
    [UsedImplicitly]
    public class FileLoggerSettings : LoggerSettings, IFileLoggerSettings
    {
        public string TraceFilename { get; set; }
        public string PerformanceFilename { get; set; }
        public string MetricFilename { get; set; }
        public MessageFormat MessageFormat { get; set; }
    }
}
