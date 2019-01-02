using JetBrains.Annotations;


namespace ErikTheCoder.Logging.Settings
{
    public interface IFileLoggerSettings : ILoggerSettings
    {
        // ReSharper disable UnusedMemberInSuper.Global
        string TraceFilename { get; [UsedImplicitly] set; }
        string PerformanceFilename { get; [UsedImplicitly] set; }
        string MetricFilename { get; [UsedImplicitly] set; }
        MessageFormat MessageFormat { get; [UsedImplicitly] set; }
        // ReSharper restore UnusedMemberInSuper.Global
    }
}
