using System;
using ErikTheCoder.Utilities;


namespace ErikTheCoder.Logging
{
    public class PerformanceLog : Log
    {
        public string OperationName { get; }
        public TimeSpan OperationDuration { get; }
        

        public PerformanceLog(Guid CorrelationId, string OperationName, TimeSpan OperationDuration) : base(CorrelationId)
        {
            this.OperationName = OperationName.Truncate(100);
            this.OperationDuration = OperationDuration;
        }
    }
}
