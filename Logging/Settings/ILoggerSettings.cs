using JetBrains.Annotations;


namespace ErikTheCoder.Logging.Settings
{
    public interface ILoggerSettings
    {
        // ReSharper disable UnusedMemberInSuper.Global
        string AppName { get; [UsedImplicitly] set; }
        string ProcessName { get; [UsedImplicitly] set; }
        LogLevel TraceLogLevel { get; [UsedImplicitly] set; }
        bool EnablePerformanceLog { get; [UsedImplicitly] set; }
        bool EnableMetricLog { get; [UsedImplicitly] set; }
        bool SendTraceMessagesToConsole { get; set; }
        int? MaxTraceLogSize { get; [UsedImplicitly] set; }
        // ReSharper restore UnusedMemberInSuper.Global
    }
}
