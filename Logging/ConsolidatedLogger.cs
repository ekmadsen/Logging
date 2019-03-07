using System;
using System.Collections.Generic;
using JetBrains.Annotations;


namespace ErikTheCoder.Logging
{
    public sealed class ConsolidatedLogger : ILogger
    {
        private List<ILogger> _traceLoggers;
        private List<ILogger> _performanceLoggers;
        private List<ILogger> _metricLoggers;
        private bool _disposed;


        public ConsolidatedLogger(List<ILogger> Loggers) : this(Loggers, Loggers, Loggers)
        {
        }


        [UsedImplicitly]
        public ConsolidatedLogger(List<ILogger> TraceLoggers, List<ILogger> PerformanceLoggers, List<ILogger> MetricLoggers)
        {
            _traceLoggers = TraceLoggers;
            _performanceLoggers = PerformanceLoggers;
            _metricLoggers = MetricLoggers;
        }


        ~ConsolidatedLogger() => Dispose(false);


        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }


        // See Microsoft-recommended dispose pattern at https://docs.microsoft.com/en-us/dotnet/standard/garbage-collection/implementing-dispose.
        private void Dispose(bool Disposing)
        {
            if (_disposed) return;
            // Free unmanaged objects.
            if (_traceLoggers != null) foreach (ILogger logger in _traceLoggers) logger?.Dispose();
            if (_performanceLoggers != null) foreach (ILogger logger in _performanceLoggers) logger?.Dispose();
            if (_metricLoggers != null) foreach (ILogger logger in _metricLoggers) logger?.Dispose();
            if (Disposing)
            {
                // Free managed objects.
                _traceLoggers = null;
                _performanceLoggers = null;
                _metricLoggers = null;
            }
            _disposed = true;
        }


        // ReSharper disable once UnusedMember.Global
        public static ILogger GetNullLogger() => new ConsolidatedLogger(null, null, null);


        public void Log(LogLevel LogLevel) 
        {
            if (_traceLoggers != null) foreach (ILogger logger in _traceLoggers) logger?.Log(LogLevel);
        }


        public void Log(string Message, LogLevel LogLevel)
        {
            if (_traceLoggers != null) foreach (ILogger logger in _traceLoggers) logger?.Log(Message, LogLevel);
        }


        public void Log(Guid CorrelationId, string Message, LogLevel LogLevel)
        {
            if (_traceLoggers != null) foreach (ILogger logger in _traceLoggers) logger?.Log(CorrelationId, Message, LogLevel);
        }


        public void Log(Exception Exception, LogLevel LogLevel) => Log(new SimpleException(Exception), LogLevel);


        public void Log(SimpleException Exception, LogLevel LogLevel)
        {
            if (_traceLoggers != null) foreach (ILogger logger in _traceLoggers) logger?.Log(Exception, LogLevel);
        }


        public void Log(Guid CorrelationId, Exception Exception, LogLevel LogLevel) => Log(CorrelationId, new SimpleException(Exception), LogLevel);


        public void Log(Guid CorrelationId, SimpleException Exception, LogLevel LogLevel)
        {
            if (_traceLoggers != null) foreach (ILogger logger in _traceLoggers) logger?.Log(CorrelationId, Exception, LogLevel);
        }


        public void LogPerformance(Guid CorrelationId, string OperationName, TimeSpan OperationDuration)
        {
            if (_performanceLoggers != null) foreach (ILogger logger in _performanceLoggers) logger.LogPerformance(CorrelationId, OperationName, OperationDuration);
        }


        public void LogMetric(string ItemId, string MetricName, DateTime MetricValue)
        {
            if (_metricLoggers != null) foreach (ILogger logger in _metricLoggers) logger.LogMetric(ItemId, MetricName, MetricValue);
        }


        public void LogMetric(Guid CorrelationId, string ItemId, string MetricName, DateTime MetricValue)
        {
            if (_metricLoggers != null) foreach (ILogger logger in _metricLoggers) logger.LogMetric(CorrelationId, ItemId, MetricName, MetricValue);
        }


        public void LogMetric(string ItemId, string MetricName, int MetricValue)
        {
            if (_metricLoggers != null) foreach (ILogger logger in _metricLoggers) logger.LogMetric(ItemId, MetricName, MetricValue);
        }


        public void LogMetric(Guid CorrelationId, string ItemId, string MetricName, int MetricValue)
        {
            if (_metricLoggers != null) foreach (ILogger logger in _metricLoggers) logger.LogMetric(CorrelationId, ItemId, MetricName, MetricValue);
        }


        public void LogMetric(string ItemId, string MetricName, string MetricValue)
        {
            if (_metricLoggers != null) foreach (ILogger logger in _metricLoggers) logger.LogMetric(ItemId, MetricName, MetricValue);
        }


        public void LogMetric(Guid CorrelationId, string ItemId, string MetricName, string MetricValue)
        {
            if (_metricLoggers != null) foreach (ILogger logger in _metricLoggers) logger.LogMetric(CorrelationId, ItemId, MetricName, MetricValue);
        }
    }
}
