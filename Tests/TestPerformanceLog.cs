using System;
using System.Diagnostics;
using System.Threading.Tasks;
using NUnit.Framework;


namespace ErikTheCoder.Logging.Tests
{
    [TestFixture]
    public class TestPerformanceLog
    {
        [Test]
        public async Task Log()
        {
            var stopwatch = Stopwatch.StartNew();
            await Task.Delay(TimeSpan.FromSeconds(1));
            stopwatch.Stop();
            ApplicationResources.Logger.LogPerformance(Guid.NewGuid(), nameof(Log), stopwatch.Elapsed);
        }
    }
}
