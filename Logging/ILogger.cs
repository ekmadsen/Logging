using System;
using JetBrains.Annotations;


namespace ErikTheCoder.Logging
{
    public interface ILogger : IDisposable
    {
        void Log(LogLevel LogLevel = LogLevel.Debug);
        void Log(string Message, LogLevel LogLevel = LogLevel.Debug);
        void Log(Guid CorrelationId, string Message, LogLevel LogLevel = LogLevel.Debug);
        [UsedImplicitly] void Log(Exception Exception, LogLevel LogLevel = LogLevel.CriticalError);
        void Log(SimpleException Exception, LogLevel LogLevel = LogLevel.CriticalError);
        [UsedImplicitly] void Log(Guid CorrelationId, Exception Exception, LogLevel LogLevel = LogLevel.CriticalError);
        void Log(Guid CorrelationId, SimpleException Exception, LogLevel LogLevel = LogLevel.CriticalError);
        void LogPerformance(Guid CorrelationId, string OperationName, TimeSpan OperationDuration);
        void LogMetric(string ItemId, string MetricName, DateTime MetricValue);
        void LogMetric(Guid CorrelationId, string ItemId, string MetricName, DateTime MetricValue);
        void LogMetric(string ItemId, string MetricName, int MetricValue);
        void LogMetric(Guid CorrelationId, string ItemId, string MetricName, int MetricValue);
        void LogMetric(string ItemId, string MetricName, string MetricValue);
        void LogMetric(Guid CorrelationId, string ItemId, string MetricName, string MetricValue);
    }
}
