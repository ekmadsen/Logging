using System;
using ErikTheCoder.Utilities;


namespace ErikTheCoder.Logging
{
    public class MetricLog : Log
    {
        public string ItemId { get; }
        public string MetricName { get; }
        public DateTime? DateTimeValue { get; }
        public int? IntValue { get; }
        public string TextValue { get; }
        


        public MetricLog(Guid CorrelationId, string ItemId, string MetricName, DateTime? DateTimeValue, int? IntValue, string TextValue) : base(CorrelationId)
        {
            this.ItemId = ItemId;
            this.MetricName = MetricName.Truncate(100);
            this.DateTimeValue = DateTimeValue;
            this.IntValue = IntValue;
            this.TextValue = TextValue.Truncate(100);
        }
    }
}
