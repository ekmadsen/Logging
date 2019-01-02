using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using ErikTheCoder.Logging.Settings;


namespace ErikTheCoder.Logging
{
    // This zero latency, thread-safe class queues logs and writes them on a ThreadPool thread.  This avoids blocking the caller to wait for I/O.
    public abstract class ConcurrentLoggerBase : ILogger
    {
        private const int _queueIntervalMsec = 100;
        private readonly LoggerSettings _settings;
        private readonly string _exeLocation;
        private readonly string _criticalErrorFilename;
        private readonly BlockingCollection<TraceLog> _traceQueue;
        private readonly BlockingCollection<PerformanceLog> _performanceQueue;
        private readonly BlockingCollection<MetricLog> _metricQueue;
        private readonly Timer _timer;
        private readonly List<Task> _tasks;
        private bool _disposed;


        protected ConcurrentLoggerBase(LoggerSettings Settings)
        {
            _settings = Settings;
            _exeLocation = Assembly.GetEntryAssembly()?.Location ?? Assembly.GetExecutingAssembly().Location;
            _criticalErrorFilename = Path.Combine(Path.GetDirectoryName(_exeLocation) ?? @"C:\", $"{Path.GetFileNameWithoutExtension(_exeLocation)}.log");
            // Create queues.
            int queues = 0;
            if (Settings.TraceLogLevel != LogLevel.None)
            {
                _traceQueue = new BlockingCollection<TraceLog>(new ConcurrentQueue<TraceLog>());
                queues++;
            }
            if (Settings.EnablePerformanceLog)
            {
                _performanceQueue = new BlockingCollection<PerformanceLog>(new ConcurrentQueue<PerformanceLog>());
                queues++;
            }
            if (Settings.EnableMetricLog)
            {
                _metricQueue = new BlockingCollection<MetricLog>(new ConcurrentQueue<MetricLog>());
                queues++;
            }
            if (queues > 0)
            {
                // Cannot await tasks because constructor cannot be marked async.  Create timer instead.
                // Timer calls method on a ThreadPool thread.
                _tasks = new List<Task>(queues);
                _timer = new Timer(WriteLogs, null, TimeSpan.Zero, TimeSpan.FromMilliseconds(_queueIntervalMsec));
            }
        }


        // See Microsoft-recommended dispose pattern at https://docs.microsoft.com/en-us/dotnet/standard/garbage-collection/implementing-dispose.
        ~ConcurrentLoggerBase() => Dispose(false);


        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }


        protected virtual void Dispose(bool Disposing)
        {
            if (_disposed) return;
            while ((_traceQueue?.Count > 0) || (_performanceQueue?.Count > 0) || (_metricQueue?.Count > 0)) Thread.Sleep(_queueIntervalMsec); // Wait for queues to drain.
            if (Disposing) {} // Free managed objects.
            // Free unmanaged objects.
            _timer?.Dispose();
            _traceQueue?.Dispose();
            _performanceQueue?.Dispose();
            _metricQueue?.Dispose();
            _disposed = true;
        }


        public void Log(LogLevel LogLevel) => Log(Guid.Empty, null, LogLevel, _settings.SendTraceMessagesToConsole);


        public void Log(string Message, LogLevel LogLevel) => Log(Guid.Empty, Message, LogLevel, _settings.SendTraceMessagesToConsole);


        public void Log(Guid CorrelationId, string Message, LogLevel LogLevel) => Log(CorrelationId, Message, LogLevel, _settings.SendTraceMessagesToConsole);


        public void Log(Exception Exception, LogLevel LogLevel) => Log(new SimpleException(Exception), LogLevel);
        

        public void Log(SimpleException Exception, LogLevel LogLevel) => Log(Guid.Empty, Exception.GetSummary(true, true), LogLevel, _settings.SendTraceMessagesToConsole);


        public void Log(Guid CorrelationId, Exception Exception, LogLevel LogLevel) => Log(CorrelationId, new SimpleException(Exception), LogLevel);


        public void Log(Guid CorrelationId, SimpleException Exception, LogLevel LogLevel) => Log(CorrelationId, Exception.GetSummary(true, true), LogLevel, _settings.SendTraceMessagesToConsole);


        private void Log(Guid CorrelationId, string Message, LogLevel LogLevel, bool SendToConsole)
        {
            if (LogLevel <= _settings.TraceLogLevel)
            {
                string message = _settings.MaxTraceLogSize.HasValue ? Message.Truncate(_settings.MaxTraceLogSize.Value) : Message;
                TraceLog traceLog = new TraceLog(CorrelationId, message, LogLevel);
                FormatMessage(traceLog);
                _traceQueue?.Add(traceLog);
                if (SendToConsole) Console.WriteLine(traceLog.Message);
            }
        }


        public void LogPerformance(Guid CorrelationId, string OperationName, TimeSpan OperationDuration) => _performanceQueue?.Add(new PerformanceLog(CorrelationId, OperationName, OperationDuration));


        public void LogMetric(string ItemId, string MetricName, DateTime MetricValue) => LogMetric(Guid.Empty, ItemId, MetricName, MetricValue, null, null);


        public void LogMetric(Guid CorrelationId, string ItemId, string MetricName, DateTime MetricValue) => LogMetric(CorrelationId, ItemId, MetricName, MetricValue, null, null);


        public void LogMetric(string ItemId, string MetricName, int MetricValue) => LogMetric(Guid.Empty, ItemId, MetricName, null, MetricValue, null);


        public void LogMetric(Guid CorrelationId, string ItemId, string MetricName, int MetricValue) => LogMetric(CorrelationId, ItemId, MetricName, null, MetricValue, null);


        public void LogMetric(string ItemId, string MetricName, string MetricValue) => LogMetric(Guid.Empty, ItemId, MetricName, null, null, MetricValue);


        public void LogMetric(Guid CorrelationId, string ItemId, string MetricName, string MetricValue) => LogMetric(CorrelationId, ItemId, MetricName, null, null, MetricValue);


        private void LogMetric(Guid CorrelationId, string ItemId, string MetricName, DateTime? DateTimeValue, int? IntValue, string TextValue) =>
            _metricQueue?.Add(new MetricLog(CorrelationId, ItemId, MetricName, DateTimeValue, IntValue, TextValue));


        private void WriteLogs(object State)
        {
            try
            {
                // Prevent overlap if method execution time exceeds timer interval.
                _timer.Change(Timeout.Infinite, Timeout.Infinite);
                bool traceLogWritten = false;
                bool performanceLogWritten = false;
                bool metricLogWritten = false;
                Task task;
                while ((_traceQueue?.Count > 0) || (_performanceQueue?.Count > 0) || (_metricQueue?.Count > 0))
                {
                    // At least one queue has logs.
                    // Drain the queues.
                    _tasks.Clear();
                    if ((_traceQueue != null) && _traceQueue.TryTake(out TraceLog traceLog))
                    {
                        // Write trace log.
                        task = WriteLogAsync(traceLog);
                        _tasks.Add(task);
                        traceLogWritten = true;
                    }
                    if ((_performanceQueue != null) && _performanceQueue.TryTake(out PerformanceLog performanceLog))
                    {
                        // Write performance log.
                        task = WriteLogAsync(performanceLog);
                        _tasks.Add(task);
                        performanceLogWritten = true;
                    }
                    if ((_metricQueue != null) && _metricQueue.TryTake(out MetricLog metricLog))
                    {
                        // Write metric log.
                        task = WriteLogAsync(metricLog);
                        _tasks.Add(task);
                        metricLogWritten = true;
                    }
                    if (_tasks.Count > 0) Task.WaitAll(_tasks.ToArray());
                }
                // Queues drained.
                _tasks.Clear();
                if (traceLogWritten)
                {
                    task = TraceQueueDrained();
                    _tasks.Add(task);
                }
                if (performanceLogWritten)
                {
                    task = PerformanceQueueDrained();
                    _tasks.Add(task);
                }
                if (metricLogWritten)
                {
                    task = MetricQueueDrained();
                    _tasks.Add(task);
                }
                if (_tasks.Count > 0) Task.WaitAll(_tasks.ToArray());
            }
            catch (Exception exception)
            {
                WriteCriticalError(exception);
            }
            finally
            {
                if (!_disposed) _timer.Change(_queueIntervalMsec, _queueIntervalMsec); // Enable timer to fire again.
            }
        }


        protected abstract Task WriteLogAsync(TraceLog Log);


        protected abstract Task WriteLogAsync(PerformanceLog Log);


        protected abstract Task WriteLogAsync(MetricLog Log);


        protected virtual Task TraceQueueDrained()
        {
            return Task.CompletedTask;
        }


        protected virtual Task PerformanceQueueDrained() => Task.CompletedTask;


        protected virtual Task MetricQueueDrained() => Task.CompletedTask;


        protected virtual void FormatMessage(TraceLog Log)
        {
        }


        protected void WriteCriticalError(Exception Exception)
        {
            string errorMessage = $"Error occurred in {_exeLocation}.{Environment.NewLine}{Exception.GetSummary(true, true)}{Environment.NewLine}";
            try
            {
                // Attempt to write error to local text file.
                File.AppendAllText(_criticalErrorFilename, errorMessage);
            }
            catch
            {
                // Don't throw exceptions.
            }
        }
    }
}