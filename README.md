# Logging
A zero latency, thread-safe logger that writes to files and / or a database.

## Motivation ##

I was motivated to write my own logging component for the following reasons.

1. It is unclear whether third-party logging solutions are thread-safe.  To avoid unnecessary allocations (compared to Transient or Scoped), I want to use a Singleton-scoped instance that is dependency-injected during the startup of ASP.NET Core MVC websites or WebAPI services.  This Singleton-scoped instance, of course, must be safe for use by multiple controller instances responding to multiple, concurrent HTTP requests.
2. It is unclear whether third-party logging solutions write logs on a background thread.  I want to write copious logs in my source code without impacting application performance.
3. It's possible to answer the questions I raise in reasons 1 and 2 with a little research.  But I didn't want to expend the mental energy to read and understand someone's else code when I could direct that energy toward writing my own code.  In addition, writing my own code has the advantage of not introducing bloat (features I don't require).  See the next reason.
3. While it's important to "know your resources", that is, leverage components freely available on the Internet, I do not blindly follow this guidance when the component I need is easy to write.  Why reference a bloated logging solution that's attempting to be all things to all people when I can write my own solution that satisfies my requirements in a few hundred lines of code?  Don't blindly be a mash-up artist.
4. When faced with the choice of mashing together third-party components or writing your own...
    A. And the two approaches require roughly equal amounts of mental energy...
    B. Considering initial effort to [grok](http://www.grokcode.com/95/definition-and-origin-of-grok/) the third-party components or write your own component...
    C. Considering on-going efforts to work around kludges caused by third-party components that don't do exectly what you need...
5. Write your own code.

## Features ##


## Limitations ##

This component relies on [BlockingCollection](https://docs.microsoft.com/en-us/dotnet/standard/collections/thread-safe/blockingcollection-overview), so logs accumulate in process memory before they're written to disk or to a database.  Therefore, this component may use large amounts of memory in high-traffic websites and services.  This has not been an issue for me, though I admit I have not stress-tested it.

## Usage ##


## Example Output ##
