using System;


namespace ErikTheCoder.Logging
{
    public static class ExtensionMethods
    {
        public static string GetSummary(this Exception Exception, bool IncludeStackTrace = false, bool RecurseInnerExceptions = false)
        {
            SimpleException exception = new SimpleException(Exception, Guid.Empty, null, null);
            return exception.GetSummary(IncludeStackTrace, RecurseInnerExceptions);
        }


        public static string Truncate(this string Text, int MaxLength)
        {
            if (string.IsNullOrEmpty(Text)) return Text;
            return Text.Length <= MaxLength ? Text : Text.Substring(0, MaxLength);
        }
    }
}
