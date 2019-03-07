using System;
using System.IO;
using System.Threading.Tasks;
using ErikTheCoder.Logging.Settings;


namespace ErikTheCoder.Logging
{
    public class ConcurrentFileLogger : ConcurrentLoggerBase
    {
        private const int _logLevelPadding = 15;
        private FileLoggerSettings _settings;
        private StreamWriter _traceWriter;
        private StreamWriter _performanceWriter;
        private StreamWriter _metricWriter;
        private bool _disposed;


        public ConcurrentFileLogger(FileLoggerSettings Settings) : base(Settings)
        {
            _settings = Settings;
            // Open log writers.
            if (!string.IsNullOrWhiteSpace(Settings.TraceFilename))
            {
                if (!File.Exists(Settings.TraceFilename)) File.AppendAllText(Settings.TraceFilename, null);
                FileStream traceStream = File.Open(Settings.TraceFilename, FileMode.Append, FileAccess.Write, FileShare.Read);
                _traceWriter = new StreamWriter(traceStream) { AutoFlush = false }; // AutoFlush degrades performance.
            }
            if (!string.IsNullOrWhiteSpace(Settings.PerformanceFilename))
            {
                if (!File.Exists(Settings.PerformanceFilename))
                {
                    // Create performance CSV file with header.
                    File.AppendAllText(Settings.PerformanceFilename, $"\"Timestamp\",\"Correlation ID\",\"Operation Name\",\"Operation Duration (sec)\"{Environment.NewLine}");
                }
                FileStream performanceStream = File.Open(Settings.PerformanceFilename, FileMode.Append, FileAccess.Write, FileShare.Read);
                _performanceWriter = new StreamWriter(performanceStream) { AutoFlush = false }; // AutoFlush degrades performance.
            }
            if (!string.IsNullOrWhiteSpace(Settings.MetricFilename))
            {
                if (!File.Exists(Settings.MetricFilename))
                {
                    // Create metric CSV file with header.
                    File.AppendAllText(Settings.MetricFilename, $"\"Timestamp\",\"Correlation ID\",\"Item ID\",\"Metric Name\",\"DateTime Value\",\"Int Value\",\"Text Value\"{Environment.NewLine}");
                }
                FileStream metricStream = File.Open(Settings.MetricFilename, FileMode.Append, FileAccess.Write, FileShare.Read); // AutoFlush degrades performance.
                _metricWriter = new StreamWriter(metricStream) { AutoFlush = false }; // AutoFlush degrades performance.
            }
        }


        // See Microsoft-recommended dispose pattern at https://docs.microsoft.com/en-us/dotnet/standard/garbage-collection/implementing-dispose.
        protected override void Dispose(bool Disposing)
        {
            if (_disposed) return;
            // Call base class implementation to ensure queues drain.
            base.Dispose(Disposing);
            if (Disposing)
            {
                // Free managed objects.
                _settings = null;
            }
            // Free unmanaged objects.
            _traceWriter?.Dispose();
            _traceWriter = null;
            _performanceWriter?.Dispose();
            _performanceWriter = null;
            _metricWriter?.Dispose();
            _metricWriter = null;
            _disposed = true;
        }


        protected override async Task WriteLogAsync(TraceLog Log)
        {
            if (_traceWriter != null) await _traceWriter.WriteLineAsync(Log.Message);
        }


        protected override async Task TraceQueueDrained()
        {
            if (_traceWriter != null) await _traceWriter.FlushAsync();
        }


        protected override async Task WriteLogAsync(PerformanceLog Log)
        {
            if (_performanceWriter != null) await _performanceWriter.WriteLineAsync($"\"{Log.Timestamp:o}\",\"{Log.CorrelationId.ToString().ToUpper()}\",\"{Log.OperationName}\",\"{Log.OperationDuration.TotalSeconds:0.0000000}\"");
        }


        protected override async Task PerformanceQueueDrained()
        {
            if (_performanceWriter != null) await _performanceWriter.FlushAsync();
        }


        protected override async Task WriteLogAsync(MetricLog Log)
        {
            if (_metricWriter != null)
            {
                await _metricWriter.WriteLineAsync($"\"{Log.Timestamp:o}\",\"{Log.CorrelationId.ToString().ToUpper()}\",\"{Log.ItemId}\",\"{Log.MetricName}\",\"{Log.DateTimeValue?.ToString("o")}\",\"{Log.IntValue}\",\"{Log.TextValue}\"");
            }
        }


        protected override async Task MetricQueueDrained()
        {
            if (_metricWriter != null) await _metricWriter.FlushAsync();
        }


        protected  override void FormatMessage(TraceLog TraceLog)
        {
            switch (_settings.MessageFormat)
            {
                case MessageFormat.MessageOnly:
                    // No formatting required.
                    break;
                case MessageFormat.IncludeTimestamp:
                    TraceLog.Message = $"{TraceLog.Timestamp:o}  {TraceLog.Message}";
                    break;
                case MessageFormat.IncludeTimestampCorId:
                    TraceLog.Message = $"{TraceLog.Timestamp:o}  {TraceLog.CorrelationId.ToString().ToUpper()}  {TraceLog.Message}";
                    break;
                case MessageFormat.IncludeTimestampCorIdLevel:
                    TraceLog.Message = $"{TraceLog.Timestamp:o}  {TraceLog.CorrelationId.ToString().ToUpper()}  {TraceLog.LogLevel.ToString().PadRight(_logLevelPadding)}  {TraceLog.Message}";
                    break;
                default:
                    throw new Exception($"{_settings.MessageFormat} not supported.");
            }
        }
    }
}
