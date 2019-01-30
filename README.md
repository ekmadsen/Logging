# Logging
A zero latency, thread-safe logger that writes to files and / or a database.

## Motivation ##

I was motivated to write my own logging component for the following reasons.

* It is unclear whether third-party logging solutions were thread-safe.  To avoid unnecessary allocations (compared to Transient or Scoped), I want to use a Singleton-scoped instance that is dependency-injected during the startup of ASP.NET Core MVC websites or WebAPI services and is safe for use by multiple controller instances responding to multiple, concurrent HTTP requests.
* It is unclear whether third-party logging solutions write logs on a background thread.  I want to write copious logs in my source code without impacting code performance.
* While it's important to "know your resources", that is, leverage components freely available on the Internet, I do not blindly follow this guidance when the component I need should be easy to write.  Why reference a bloated logging solution that's attempting to be all things to all people when I can write my own solution that satisfies all my requirements in a few hundred lines of code?

## Features ##


## Usage  ##
