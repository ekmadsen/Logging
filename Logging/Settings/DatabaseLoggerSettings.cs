using JetBrains.Annotations;


namespace ErikTheCoder.Logging.Settings
{
    [UsedImplicitly]
    public class DatabaseLoggerSettings : LoggerSettings, IDatabaseLoggerSettings
    {
        public string Connection { get; set; }
    }
}
