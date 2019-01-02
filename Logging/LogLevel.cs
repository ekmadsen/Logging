using System;


namespace ErikTheCoder.Logging
{
    [Serializable]
    public enum LogLevel
    {
        // Ordered in increasing level of detail.
        // Integer values correspond to Id column in AppLogs database.
        // ReSharper disable UnusedMember.Global
        None = 0,
        CriticalError = 1,
        Error = 2,
        Warning = 3,
        Info = 4,
        Debug = 5
        // ReSharper restore UnusedMember.Global
    }
}
