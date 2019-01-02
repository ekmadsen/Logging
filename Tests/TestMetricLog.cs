using System;
using NUnit.Framework;


namespace ErikTheCoder.Logging.Tests
{
    [TestFixture]
    public class TestMetricLog
    {
        [Test]
        public void LogDateTime() => ApplicationResources.Logger.LogMetric(Guid.NewGuid(), "Party Like It's", "DateTime Metric", new DateTime(1999, 12, 31));


        [Test]
        public void LogInt() => ApplicationResources.Logger.LogMetric(Guid.NewGuid(), "Life, The Universe, and Everything", "Int Metric", 42);


        [Test]
        public void LogString() => ApplicationResources.Logger.LogMetric(Guid.NewGuid(), "Violin", "String Metric", "Stradivarius");
    }
}
