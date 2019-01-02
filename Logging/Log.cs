using System;


namespace ErikTheCoder.Logging
{
    public abstract class Log
    {
        public DateTime Timestamp { get; }
        public Guid CorrelationId { get; }


        private Log()
        {
            Timestamp = DateTime.Now;
            CorrelationId = Guid.Empty;
        }


        protected Log(Guid CorrelationId) : this()
        {
            this.CorrelationId = CorrelationId;
        }
    }
}
