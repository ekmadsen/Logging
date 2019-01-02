using System;
using NUnit.Framework;


namespace ErikTheCoder.Logging.Tests
{
    [TestFixture]
    public class TestTraceLog
    {
        [Test]
        public void LogMessage() => ApplicationResources.Logger.Log("Logging Message.");


        [Test]
        public void LogCorrelationIdMessage() => ApplicationResources.Logger.Log(Guid.NewGuid(), "Logging CorrelationId and Message.");


        [Test]
        public void LogCorrelationIdMessageLogLevel() => ApplicationResources.Logger.Log(Guid.NewGuid(), "Logging CorrelationID and Message with a LogLevel.", LogLevel.Info);


        [Test]
        public void LogMessageLogLevel() => ApplicationResources.Logger.Log("Logging Message with a LogLevel.", LogLevel.Error);


        [Test]
        public void LogException() => ApplicationResources.Logger.Log(new Exception("Logging Exception."));


        [Test]
        public void LogSimpleException() => ApplicationResources.Logger.Log(new SimpleException(new Exception("Logging SimpleException.")));


        [Test]
        public void LogBlankLine() => ApplicationResources.Logger.Log();
    }
}
