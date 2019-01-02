using System;


namespace ErikTheCoder.Logging
{
    public class TraceLog : Log
    {
        public string Message { get; set; }
        

        public LogLevel LogLevel { get; }
        

        public TraceLog(Guid CorrelationId, string Message, LogLevel LogLevel) : base(CorrelationId)
        {
            this.Message = Message;
            this.LogLevel = LogLevel;
        }
    }
}
