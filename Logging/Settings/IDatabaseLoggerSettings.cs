using JetBrains.Annotations;


namespace ErikTheCoder.Logging.Settings
{
    public interface IDatabaseLoggerSettings : ILoggerSettings
    {
        // ReSharper disable UnusedMemberInSuper.Global
        string Connection { get; [UsedImplicitly] set; }
        // ReSharper restore UnusedMemberInSuper.Global
    }
}
