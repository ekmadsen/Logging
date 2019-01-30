# Logging
A zero latency, thread-safe logger that writes to files and / or a database.

## Motivation ##

I was motivated to write my own logging component for the following reasons.

1. It is unclear whether third-party logging solutions are thread-safe.  To avoid unnecessary allocations (compared to Transient or Scoped), I want to use a Singleton-scoped instance that is dependency-injected during the startup of ASP.NET Core MVC websites or WebAPI services.  This Singleton-scoped instance, of course, must be safe for use by multiple controller instances responding to multiple, concurrent HTTP requests.
2. It is unclear whether third-party logging solutions write logs on a background thread.  I want to write copious logs in my source code without impacting application performance.
3. It's possible to answer the questions I raise in reasons 1 and 2 with a little research.  But I didn't want to expend the mental energy to read and understand someone's else code when I could direct that energy toward writing my own code.  In addition, writing my own code has the advantage of not introducing bloat (features I don't require).
3. While it's important to "know your resources", that is, leverage components freely available on the Internet, I do not blindly follow this guidance when the component I need is easy to write.  Why reference a bloated logging solution that's attempting to be all things to all people when I can write my own solution that satisfies my requirements in a few hundred lines of code?  Don't blindly be a mash-up artist.
4. When faced with the choice of mashing together third-party components or writing your own...
   - If the two approaches require roughly equal amounts of mental energy...
   - If the initial effort to [grok](http://www.grokcode.com/95/definition-and-origin-of-grok/) the third-party components is high or effort to write your own component is low...
   - If persistent effort is required to work around kludges caused by third-party components that don't do exectly what you need...
5. Write your own code.

## Features ##

* Safe for use as a Singleton-scoped instance in multi-threaded, highly-concurrent applications such as websites and services.
* Targets .NET Standard 2.0 so it may be used in .NET Core or .NET Framework runtimes.
* Writes tracing, performance, and metric logs.
* Writes to files (one file each for tracing, performance, and metric) or a database.
* Writes to both files and a database via the [ConsolidatedLogger](https://github.com/ekmadsen/Logging/blob/master/Logging/ConsolidatedLogger.cs) class.  Why write to both targets?  You could configure the file and database loggers differently or enable one of the loggers to send trace messages to the Console in addition to its target.  Typically, I write only to a database logger.
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

If you're developing an ASP.NET Core MVC website or WebAPI service, I highly recommend installing my [AspNetCore.Middleware](https://github.com/ekmadsen/AspNetCore.Middleware) solution, which uses this component to *automatically* write tracing, performance, and metric logs for all invocations of controller actions (page hits and service method calls).  It also automatically writes trace logs for all uncaught exceptions and responds to the caller with exception details formatted as JSON (for services) or HTML (for websites).  This enables exception details to flow from a SQL database through a service to a website, displaying a full cross-process stack trace (related by CorrelationId) in the web browser.  This greatly reduces the time it takes for a programmer to identify the root cause of application exceptions.

What do I mean by *automatic*?  The programmer need not include any boilerplate code in their controllers.  See my [AspNetCore.Middleware](https://github.com/ekmadsen/AspNetCore.Middleware) solution for more details.

## Limitations ##

This component relies on [BlockingCollection](https://docs.microsoft.com/en-us/dotnet/standard/collections/thread-safe/blockingcollection-overview), so logs accumulate in process memory before they're written to disk or to a database.  This async design (fast I/O writes to memory on the application thread, slow I/O writes to a data store on a background thread) is what makes this component so fast, causing practically zero latency on your application thread.  As a trade off (speed for memory), this component may use large amounts of memory in high-traffic websites and services.  This has not been an issue for me, though I admit I have not stress-tested the component.

## Installation ##

* Use SQL Server Management Studio to locate an existing database or create a new database.
* Run the [CreateDatabase.sql](https://github.com/ekmadsen/Logging/blob/master/CreateDatabase.sql) script to create the tables and views used by this solution.  The script creates SQL objects in a "Logging" schema.  Obviously, if you install this solution in a dedicated database there's no risk of colliding with the names of existing SQL objects.  However, if you install this solution in an existing database the schema minimizes the risk of colliding with existing SQL objects.
* Reference this component in your solution via its [NuGet package](https://www.nuget.org/packages/ErikTheCoder.Logging/).

## Usage (Writing Logs) ##

Construct file and database loggers:
```C#
Guid correlationId = Guid.NewGuid(); // Will use in later code sample.
string appName = "Sales Orders";
string processName = "Service";
// I recommend you bind these settings directly from appSettings.json, but I'll write them explicitly for clarity.
FileLoggerSettings fileLoggerSettings = new FileLoggerSettings
{
    AppName = appName,
    ProcessName = serviceName,
    MessageFormat = MessageFormat.IncludeTimestampCorIdLevel,
    TraceFilename = @"C:\Users\Erik\Documents\SalesOrdersTrace.log",
    PerformanceFilename = @"C:\Users\Erik\Documents\SalesOrdersPerformance.csv",
    MetricFilename = @"C:\Users\Erik\Documents\SalesOrdersMetric.csv"
};
DatabaseLoggerSettings databaseLoggerSettings = new DatabaseLoggerSettings
{
    AppName = appname,
    ProcessName = processName,
    TraceLogLevel = LogLevel.Debug,
    Connection = "Data Source=SqlServerName;Initial Catalog=LoggingDatabaseName;Integrated Security=True"    
};
ILogger fileLogger = new ConcurrentFileLogger(fileLoggerSettings);
ILogger databaseLogger = new ConcurrentDatabaseLogger(databaseLoggerSettings);
ILogger consolidatedLogger = new ConsolidatedLogger(new List<ILogger>{ fileLogger, databaseLogger });
```

Log a message with or without a correlation ID:
```C#
logger.Log(correlationId, $"{Program.AppSettings.Logger.ProcessName} starting.");
logger.Log($"{Program.AppSettings.Logger.ProcessName} starting.");
```

Configure dependency injection in ASP.NET Core:
```C#
Services.AddSingleton(typeof(ILogger), consolidatedLogger);
// Now any controller can request the logger by including an ILogger Logger parameter in its constructor.
```

Log an exception with or without a correlation ID:
```C#
try
{
    Foo();
}
catch(Exception exception)
{
    logger.Log(correlationId, exception);
    logger.Log(exception);
}
```

Log performance with or without a correlation ID:
```C#
Stopwatch stopwatch = Stopwatch.StartNew();
ExpensiveOperation();
stopwatch.Stop();
logger.LogPerformance(correlationId, nameof(ExpensiveOperation), stopwatch.Elapsed);
logger.LogPerformance(nameof(ExpensiveOperation), stopwatch.Elapsed);
```

## Benefit (Reading Logs)  ##
