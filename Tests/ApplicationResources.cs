﻿using System;
using System.Collections.Generic;
using System.IO;
using ErikTheCoder.Logging.Settings;
using Newtonsoft.Json.Linq;
using NUnit.Framework;


namespace ErikTheCoder.Logging.Tests
{
    [SetUpFixture]
    public class ApplicationResources
    {
        public static ILogger Logger { get; private set; }


        [OneTimeSetUp]
        public static void SetUp()
        {
            // Get configuration.
            var fileLoggerSettings = ParseFileLoggerConfiguration();
            var databaseLoggerSettings = ParseDatabaseLoggerConfiguration();
            databaseLoggerSettings.SendTraceMessagesToConsole = false;
            // Create file, database, and consolidated loggers.
            ILogger fileLogger = new ConcurrentFileLogger(fileLoggerSettings);
            ILogger databaseLogger = new ConcurrentDatabaseLogger(databaseLoggerSettings, new SqlDatabase());
            Logger = new ConsolidatedLogger(new List<ILogger> { fileLogger, databaseLogger });
        }


        [OneTimeTearDown]
        public static void TearDown()
        {
            // Free unmanaged objects.
            Logger?.Dispose();
            Logger = null;
        }


        private static FileLoggerSettings ParseFileLoggerConfiguration() => ParseConfigurationFile().ToObject<FileLoggerSettings>();


        private static DatabaseLoggerSettings ParseDatabaseLoggerConfiguration() => ParseConfigurationFile().ToObject<DatabaseLoggerSettings>();


        private static JObject ParseConfigurationFile()
        {
            var directory = Path.GetDirectoryName(typeof(ApplicationResources).Assembly.Location) ?? string.Empty;
            var configurationFile = Path.Combine(directory, "appSettings.json");
            if (File.Exists(configurationFile))
            {
                return JObject.Parse(File.ReadAllText(configurationFile));
            }
            throw new Exception($"Failed to load configuration file located at {configurationFile}.");
        }
    }
}
