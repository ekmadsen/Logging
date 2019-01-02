using System;
using System.Text;


namespace ErikTheCoder.Logging
{
    public static class ExtensionMethods
    {
        public static string GetSummary(this Exception Exception, bool IncludeStackTrace = false, bool RecurseInnerExceptions = false)
        {
            SimpleException exception = new SimpleException(Exception, Guid.Empty, null, null);
            return GetSummary(exception, IncludeStackTrace, RecurseInnerExceptions);
        }


        public static string GetSummary(this SimpleException Exception, bool IncludeStackTrace = false, bool RecurseInnerExceptions = false)
        {
            StringBuilder stringBuilder = new StringBuilder();
            SimpleException exception = Exception;
            while (exception != null)
            {
                // Include spaces to align text.
                stringBuilder.AppendLine($"Exception Type =             {exception.Type}");
                if (exception.CorrelationId != Guid.Empty) stringBuilder.AppendLine($"Exception Correlation ID =   {exception.CorrelationId}");
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


        public static string Truncate(this string Text, int MaxLength)
        {
            if (string.IsNullOrEmpty(Text)) return Text;
            return Text.Length <= MaxLength ? Text : Text.Substring(0, MaxLength);
        }
    }
}
