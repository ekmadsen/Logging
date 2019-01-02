using System;
using JetBrains.Annotations;


namespace ErikTheCoder.Logging
{
    public class SimpleException
    {
        public string Type { get; [UsedImplicitly] set; }
        public Guid CorrelationId { get; [UsedImplicitly] set; }
        public string ApplicationName { get; [UsedImplicitly] set; }
        public string ProcessName { get; [UsedImplicitly] set; }
        public string Message { get; [UsedImplicitly] set; }
        public string StackTrace { get; [UsedImplicitly] set; }
        public SimpleException InnerException { get; [UsedImplicitly] set; }


        public SimpleException() : this(null, Guid.Empty, null, null, null)
        {
        }


        public SimpleException(Exception Exception) : this(Exception, Guid.Empty, null, null)
        {
        }
        

        public SimpleException(SimpleException InnerException, Guid CorrelationId, string ApplicationName, string ProcessName, string Message)
        {
            Type = GetType().FullName;
            this.CorrelationId = CorrelationId;
            this.ApplicationName = ApplicationName;
            this.ProcessName = ProcessName;
            this.Message = Message;
            StackTrace = Environment.StackTrace;
            this.InnerException = InnerException;
        }


        public SimpleException(Exception Exception, Guid CorrelationId, string ApplicationName, string ProcessName)
        {
            Type = Exception.GetType().FullName;
            this.CorrelationId = CorrelationId;
            this.ApplicationName = ApplicationName;
            this.ProcessName = ProcessName;
            // Recursively copy exception details from .NET Exception object to this object.
            Exception exception = Exception;
            SimpleException simpleException = this;
            while (exception != null)
            {
                simpleException.Type = exception.GetType().FullName;
                simpleException.CorrelationId = CorrelationId;
                simpleException.ApplicationName = ApplicationName;
                simpleException.ProcessName = ProcessName;
                simpleException.Message = exception.Message;
                simpleException.StackTrace = exception.StackTrace;
                if (exception.InnerException is null) exception = null;
                else
                {
                    exception = exception.InnerException;
                    simpleException.InnerException = new SimpleException();
                    simpleException = simpleException.InnerException;
                }
            }
        }
    }
}
