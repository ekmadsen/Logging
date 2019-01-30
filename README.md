# Logging
A zero latency, thread-safe logger that writes to files and / or a database.

## Motivation ##

I was motivated to write my own logging component for the following reasons.

1. It is unclear whether third-party logging solutions are thread-safe.  To avoid unnecessary allocations (compared to Transient or Scoped), I want to use a Singleton-scoped instance that is dependency-injected during the startup of ASP.NET Core MVC websites or WebAPI services.  This Singleton-scoped instance, of course, must be safe for use by multiple controller instances responding to multiple, concurrent HTTP requests.
2. It is unclear whether third-party logging solutions write logs on a background thread.  I want to write copious logs in my source code without impacting application performance.
3. It's possible to answer the questions I raise in reasons 1 and 2 with a little research.  But I didn't want to expend the mental energy to read and understand someone's else code when I could direct that energy toward writing my own code.  In addition, writing my own code has the advantage of not introducing bloat (features I don't require).  See the next reason.
3. While it's important to "know your resources", that is, leverage components freely available on the Internet, I do not blindly follow this guidance when the component I need is easy to write.  Why reference a bloated logging solution that's attempting to be all things to all people when I can write my own solution that satisfies my requirements in a few hundred lines of code?  Don't blindly be a mash-up artist.
4. When faced with the choice of mashing together third-party components or writing your own...
   - And the two approaches require roughly equal amounts of mental energy...
   - Considering initial efforts to [grok](http://www.grokcode.com/95/definition-and-origin-of-grok/) the third-party components or write your own component...
   - Considering on-going efforts to work around kludges caused by third-party components that don't do exectly what you need...
5. Write your own code.

## Features ##

* Safe for use as a Singleton-scoped instance in multi-threaded, highly-concurrent applications such as websites and services.
* Targets .NET Standard 2.0 so it may be used in .NET Core or .NET Framework runtimes.
* Writes tracing, performance, and metric logs.
* Writes to files (one file each for tracing, performance, and metric) or a database.
* Writes to both files and a database via the[ConsolidatedLogger](https://github.com/ekmadsen/Logging/blob/master/Logging/ConsolidatedLogger.cs) class.  Why write to both targets?  You could configure the file and database logger differently or enable one of the loggers to send trace messages to the Console in addition to its target.
* Includes a CorrelationId so you may see related messages across tracing, performance, and metric logs.
* Configurable
  * AppName and ProcessName.  The ProcessName is meant to indicate the layer in your n-tier application architecture, such as "Website", "Service", or "Data Load".
  * TraceLogLevel
    * CriticalError
    * Error
    * Warning
    * Info
    * Debug
  * TraceFilename, PerformanceFilename, and MetricFilename
  * MessageFormat (for text files)
    * MessageOnly
    * IncludeTimestamp
    * IncludeTimestampCorId
    * IncludeTimestampCorIdLevel

## Related Solution ##



## Limitations ##

This component relies on [BlockingCollection](https://docs.microsoft.com/en-us/dotnet/standard/collections/thread-safe/blockingcollection-overview), so logs accumulate in process memory before they're written to disk or to a database.  Therefore, this component may use large amounts of memory in high-traffic websites and services.  This has not been an issue for me, though I admit I have not stress-tested it.

## Installation ##

* Use SQL Server Management Studio to create a new database.
* Run the CreateDatabase.sql script to create the tables and views used by this solution.  The script creates SQL objects in a "Logging" schema.  Obviously, if you install this solution in a dedicated database there's no risk of colliding with the names of existing SQL objects.  However, if you install this solution in an existing database the schema minimizes the risk of colliding with existing SQL objects.
* Reference this component in your solution via its [NuGet package](https://www.nuget.org/packages/ErikTheCoder.Logging/).

## Usage (Writing Logs) ##



## Benefit (Reading Logs)  ##
