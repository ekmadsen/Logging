using System;
using System.Text;
using JetBrains.Annotations;


namespace ErikTheCoder.Logging
{
    public class SimpleException
    {
        [UsedImplicitly] public string Type { get; [UsedImplicitly] set; }
        [UsedImplicitly] public Guid CorrelationId { get; [UsedImplicitly] set; }
        [UsedImplicitly] public string ApplicationName { get; [UsedImplicitly] set; }
        [UsedImplicitly] public string ProcessName { get; [UsedImplicitly] set; }
        [UsedImplicitly] public string Message { get; [UsedImplicitly] set; }
        [UsedImplicitly] public string StackTrace { get; [UsedImplicitly] set; }
        [UsedImplicitly] public SimpleException InnerException { get; [UsedImplicitly] set; }


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
            // Recursively copy exception details from .NET Exception object to this object.
            var exception = Exception;
            var simpleException = this;
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


        public string GetSummary(bool IncludeStackTrace = false, bool RecurseInnerExceptions = false)
        {
            var stringBuilder = new StringBuilder();
            var exception = this;
            while (exception != null)
            {
                // Include spaces to align text.
                stringBuilder.AppendLine($"Exception Type =             {exception.Type}");
                if (exception.CorrelationId != Guid.Empty) stringBuilder.AppendLine($"Exception Correlation ID =   {exception.CorrelationId.ToString().ToUpper()}");
                if (exception.ApplicationName != null) stringBuilder.AppendLine($"Exception App Name =         {exception.ApplicationName}");
                if (exception.ProcessName != null) stringBuilder.AppendLine($"Exception Process Name =     {exception.ProcessName}");
                stringBuilder.AppendLine($"Exception Message =          {exception.Message}");
                if (IncludeStackTrace) stringBuilder.AppendLine($"Exception StackTrace =       {exception.StackTrace?.TrimStart(' ')}");
                stringBuilder.AppendLine();
                stringBuilder.AppendLine();
                exception = RecurseInnerExceptions ? exception.InnerException : null;
            }
            return stringBuilder.ToString();
        }
    }
}
