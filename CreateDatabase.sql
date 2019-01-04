USE [AppLogs]
GO
/****** Object:  Table [dbo].[Apps]    Script Date: 1/2/2019 9:43:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Apps](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Apps] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Hosts]    Script Date: 1/2/2019 9:43:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Hosts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Hosts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Processes]    Script Date: 1/2/2019 9:43:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Processes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AppId] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Processes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MetricLogs]    Script Date: 1/2/2019 9:43:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MetricLogs](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[HostId] [int] NOT NULL,
	[ProcessId] [int] NOT NULL,
	[Timestamp] [datetime2](7) NOT NULL,
	[CorrelationId] [nchar](36) NOT NULL,
	[ItemId] [nvarchar](255) NULL,
	[MetricName] [nvarchar](255) NOT NULL,
	[DateTimeValue] [datetime2](7) NULL,
	[IntValue] [int] NULL,
	[TextValue] [nvarchar](255) NULL,
 CONSTRAINT [PK_MetricLogs] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[MetricLogsLastDay]    Script Date: 1/2/2019 9:43:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MetricLogsLastDay]
AS
SELECT m.Id, m.Timestamp, m.CorrelationId, h.Name AS HostName, a.Name AS AppName, p.Name AS ProcessName, m.ItemId, m.MetricName, m.DateTimeValue, m.IntValue, m.TextValue
FROM   dbo.MetricLogs AS m INNER JOIN
             dbo.Hosts AS h ON m.HostId = h.Id INNER JOIN
             dbo.Processes AS p ON m.ProcessId = p.Id INNER JOIN
             dbo.Apps AS a ON p.AppId = a.Id
WHERE (m.Timestamp > DATEADD(HOUR, - 24, GETDATE()))
GO
/****** Object:  Table [dbo].[PerformanceLogs]    Script Date: 1/2/2019 9:43:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PerformanceLogs](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[HostId] [int] NOT NULL,
	[ProcessId] [int] NOT NULL,
	[Timestamp] [datetime2](7) NOT NULL,
	[CorrelationId] [nchar](36) NOT NULL,
	[OperationName] [nvarchar](100) NOT NULL,
	[OperationDuration] [time](7) NOT NULL,
 CONSTRAINT [PK_PerformanceLogs] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[OperationsAvgDuration]    Script Date: 1/2/2019 9:43:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OperationsAvgDuration]
AS
SELECT a.Name AS AppName, pr.Name AS ProcessName, pl.OperationName, COUNT(*) AS Count, CAST(DATEADD(ms, AVG(CAST(DATEDIFF(ms, '00:00:00', CAST(pl.OperationDuration AS time)) AS BIGINT)), '00:00:00') AS Time) AS OperationAvgDuration
FROM   dbo.PerformanceLogs AS pl INNER JOIN
             dbo.Processes AS pr ON pl.ProcessId = pr.Id INNER JOIN
             dbo.Apps AS a ON pr.AppId = a.Id
GROUP BY a.Name, pr.Name, pl.OperationName
GO
/****** Object:  View [dbo].[OperationsAvgDurationLastDay]    Script Date: 1/2/2019 9:43:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OperationsAvgDurationLastDay]
AS
SELECT a.Name AS AppName, pr.Name AS ProcessName, pl.OperationName, COUNT(*) AS Count, CAST(DATEADD(ms, AVG(CAST(DATEDIFF(ms, '00:00:00', CAST(pl.OperationDuration AS time)) AS BIGINT)), '00:00:00') AS Time) AS OperationAvgDuration
FROM   dbo.PerformanceLogs AS pl INNER JOIN
             dbo.Processes AS pr ON pl.ProcessId = pr.Id INNER JOIN
             dbo.Apps AS a ON pr.AppId = a.Id
WHERE (pl.Timestamp > DATEADD(HOUR, - 24, GETDATE()))
GROUP BY a.Name, pr.Name, pl.OperationName
GO
/****** Object:  View [dbo].[PerformanceLogsLastDay]    Script Date: 1/2/2019 9:43:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PerformanceLogsLastDay]
AS
SELECT perf.Id, perf.Timestamp, perf.CorrelationId, h.Name AS HostName, a.Name AS AppName, p.Name AS ProcessName, perf.OperationName, perf.OperationDuration
FROM   dbo.PerformanceLogs AS perf INNER JOIN
             dbo.Hosts AS h ON perf.HostId = h.Id INNER JOIN
             dbo.Processes AS p ON perf.ProcessId = p.Id INNER JOIN
             dbo.Apps AS a ON p.AppId = a.Id
WHERE (perf.Timestamp > DATEADD(HOUR, - 24, GETDATE()))
GO
/****** Object:  Table [dbo].[TraceLogs]    Script Date: 1/2/2019 9:43:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TraceLogs](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[HostId] [int] NOT NULL,
	[ProcessId] [int] NOT NULL,
	[LevelId] [int] NOT NULL,
	[Timestamp] [datetime2](7) NOT NULL,
	[CorrelationId] [nchar](36) NOT NULL,
	[Message] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_TraceLogs] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TraceLogLevels]    Script Date: 1/2/2019 9:43:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TraceLogLevels](
	[Id] [int] NOT NULL,
	[Name] [nchar](20) NOT NULL,
 CONSTRAINT [PK_TraceLogLevels] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[TraceLogsLastDay]    Script Date: 1/2/2019 9:43:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TraceLogsLastDay]
AS
SELECT        TOP (100) PERCENT t.Id, t.Timestamp, t.CorrelationId, h.Name AS HostName, a.Name AS AppName, p.Name AS ProcessName, l.Id AS LogLevelId, l.Name AS LogLevel, t.Message
FROM            dbo.TraceLogs AS t INNER JOIN
                         dbo.Hosts AS h ON t.HostId = h.Id INNER JOIN
                         dbo.Processes AS p ON t.ProcessId = p.Id INNER JOIN
                         dbo.Apps AS a ON p.AppId = a.Id INNER JOIN
                         dbo.TraceLogLevels AS l ON t.LevelId = l.Id
WHERE        (t.Timestamp > DATEADD(HOUR, - 24, GETDATE()))

GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UX_Apps_Name]    Script Date: 1/2/2019 9:43:43 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_Apps_Name] ON [dbo].[Apps]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UX_Hosts_Name]    Script Date: 1/2/2019 9:43:43 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_Hosts_Name] ON [dbo].[Hosts]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_MetricLogs_CorrelationId]    Script Date: 1/2/2019 9:43:43 PM ******/
CREATE NONCLUSTERED INDEX [IX_MetricLogs_CorrelationId] ON [dbo].[MetricLogs]
(
	[CorrelationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_MetricLogs_ProcessId_ItemId]    Script Date: 1/2/2019 9:43:43 PM ******/
CREATE NONCLUSTERED INDEX [IX_MetricLogs_ProcessId_ItemId] ON [dbo].[MetricLogs]
(
	[ProcessId] ASC,
	[ItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_MetricLogs_ProcessId_MetricName]    Script Date: 1/2/2019 9:43:43 PM ******/
CREATE NONCLUSTERED INDEX [IX_MetricLogs_ProcessId_MetricName] ON [dbo].[MetricLogs]
(
	[ProcessId] ASC,
	[MetricName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_MetricLogs_ProcessId_Timestamp]    Script Date: 1/2/2019 9:43:43 PM ******/
CREATE NONCLUSTERED INDEX [IX_MetricLogs_ProcessId_Timestamp] ON [dbo].[MetricLogs]
(
	[ProcessId] ASC,
	[Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_MetricLogs_Timestamp]    Script Date: 1/2/2019 9:43:43 PM ******/
CREATE NONCLUSTERED INDEX [IX_MetricLogs_Timestamp] ON [dbo].[MetricLogs]
(
	[Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PerformanceLogs_CorrelationId]    Script Date: 1/2/2019 9:43:43 PM ******/
CREATE NONCLUSTERED INDEX [IX_PerformanceLogs_CorrelationId] ON [dbo].[PerformanceLogs]
(
	[CorrelationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PerformanceLogs_ProcessId_OperationName]    Script Date: 1/2/2019 9:43:43 PM ******/
CREATE NONCLUSTERED INDEX [IX_PerformanceLogs_ProcessId_OperationName] ON [dbo].[PerformanceLogs]
(
	[ProcessId] ASC,
	[OperationName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_PerformanceLogs_ProcessId_Timestamp]    Script Date: 1/2/2019 9:43:43 PM ******/
CREATE NONCLUSTERED INDEX [IX_PerformanceLogs_ProcessId_Timestamp] ON [dbo].[PerformanceLogs]
(
	[ProcessId] ASC,
	[Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_PerformanceLogs_Timestamp]    Script Date: 1/2/2019 9:43:43 PM ******/
CREATE NONCLUSTERED INDEX [IX_PerformanceLogs_Timestamp] ON [dbo].[PerformanceLogs]
(
	[Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_Processes_AppId]    Script Date: 1/2/2019 9:43:43 PM ******/
CREATE NONCLUSTERED INDEX [IX_Processes_AppId] ON [dbo].[Processes]
(
	[AppId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UX_Processes_AppId_Name]    Script Date: 1/2/2019 9:43:43 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_Processes_AppId_Name] ON [dbo].[Processes]
(
	[AppId] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UX_TraceLogLevels_Name]    Script Date: 1/2/2019 9:43:43 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_TraceLogLevels_Name] ON [dbo].[TraceLogLevels]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_TraceLogs_CorrelationId]    Script Date: 1/2/2019 9:43:43 PM ******/
CREATE NONCLUSTERED INDEX [IX_TraceLogs_CorrelationId] ON [dbo].[TraceLogs]
(
	[CorrelationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_TraceLogs_ProcessId_LevelId_Timestamp]    Script Date: 1/2/2019 9:43:43 PM ******/
CREATE NONCLUSTERED INDEX [IX_TraceLogs_ProcessId_LevelId_Timestamp] ON [dbo].[TraceLogs]
(
	[ProcessId] ASC,
	[LevelId] ASC,
	[Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TraceLogs_ProcessId_Timestamp]    Script Date: 1/2/2019 9:43:43 PM ******/
CREATE NONCLUSTERED INDEX [IX_TraceLogs_ProcessId_Timestamp] ON [dbo].[TraceLogs]
(
	[ProcessId] ASC,
	[Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [IX_TraceLogs_Timestamp]    Script Date: 1/2/2019 9:43:43 PM ******/
CREATE NONCLUSTERED INDEX [IX_TraceLogs_Timestamp] ON [dbo].[TraceLogs]
(
	[Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricLogs]  WITH CHECK ADD  CONSTRAINT [FK_MetricLogs_Hosts] FOREIGN KEY([HostId])
REFERENCES [dbo].[Hosts] ([Id])
GO
ALTER TABLE [dbo].[MetricLogs] CHECK CONSTRAINT [FK_MetricLogs_Hosts]
GO
ALTER TABLE [dbo].[MetricLogs]  WITH CHECK ADD  CONSTRAINT [FK_MetricLogs_Processes] FOREIGN KEY([ProcessId])
REFERENCES [dbo].[Processes] ([Id])
GO
ALTER TABLE [dbo].[MetricLogs] CHECK CONSTRAINT [FK_MetricLogs_Processes]
GO
ALTER TABLE [dbo].[PerformanceLogs]  WITH CHECK ADD  CONSTRAINT [FK_PerformanceLogs_Hosts] FOREIGN KEY([HostId])
REFERENCES [dbo].[Hosts] ([Id])
GO
ALTER TABLE [dbo].[PerformanceLogs] CHECK CONSTRAINT [FK_PerformanceLogs_Hosts]
GO
ALTER TABLE [dbo].[PerformanceLogs]  WITH CHECK ADD  CONSTRAINT [FK_PerformanceLogs_Processes] FOREIGN KEY([ProcessId])
REFERENCES [dbo].[Processes] ([Id])
GO
ALTER TABLE [dbo].[PerformanceLogs] CHECK CONSTRAINT [FK_PerformanceLogs_Processes]
GO
ALTER TABLE [dbo].[Processes]  WITH CHECK ADD  CONSTRAINT [FK_Processes_Apps] FOREIGN KEY([AppId])
REFERENCES [dbo].[Apps] ([Id])
GO
ALTER TABLE [dbo].[Processes] CHECK CONSTRAINT [FK_Processes_Apps]
GO
ALTER TABLE [dbo].[TraceLogs]  WITH CHECK ADD  CONSTRAINT [FK_TraceLogs_Hosts] FOREIGN KEY([HostId])
REFERENCES [dbo].[Hosts] ([Id])
GO
ALTER TABLE [dbo].[TraceLogs] CHECK CONSTRAINT [FK_TraceLogs_Hosts]
GO
ALTER TABLE [dbo].[TraceLogs]  WITH CHECK ADD  CONSTRAINT [FK_TraceLogs_Processes] FOREIGN KEY([ProcessId])
REFERENCES [dbo].[Processes] ([Id])
GO
ALTER TABLE [dbo].[TraceLogs] CHECK CONSTRAINT [FK_TraceLogs_Processes]
GO
ALTER TABLE [dbo].[TraceLogs]  WITH CHECK ADD  CONSTRAINT [FK_TraceLogs_TraceLogLevels] FOREIGN KEY([LevelId])
REFERENCES [dbo].[TraceLogLevels] ([Id])
GO
ALTER TABLE [dbo].[TraceLogs] CHECK CONSTRAINT [FK_TraceLogs_TraceLogLevels]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "m"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "h"
            Begin Extent = 
               Top = 6
               Left = 662
               Bottom = 102
               Right = 832
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "p"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 119
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 102
               Right = 624
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MetricLogsLastDay'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MetricLogsLastDay'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "pl"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "pr"
            Begin Extent = 
               Top = 6
               Left = 280
               Bottom = 119
               Right = 466
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 504
               Bottom = 102
               Right = 690
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'OperationsAvgDuration'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'OperationsAvgDuration'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "pl"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "pr"
            Begin Extent = 
               Top = 6
               Left = 280
               Bottom = 119
               Right = 466
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 504
               Bottom = 102
               Right = 690
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'OperationsAvgDurationLastDay'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'OperationsAvgDurationLastDay'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "perf"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 226
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "h"
            Begin Extent = 
               Top = 6
               Left = 680
               Bottom = 102
               Right = 850
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "p"
            Begin Extent = 
               Top = 6
               Left = 264
               Bottom = 119
               Right = 434
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 472
               Bottom = 102
               Right = 642
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'PerformanceLogsLastDay'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'PerformanceLogsLastDay'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "t"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "h"
            Begin Extent = 
               Top = 6
               Left = 662
               Bottom = 102
               Right = 832
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "p"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 119
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 102
               Right = 624
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "l"
            Begin Extent = 
               Top = 120
               Left = 246
               Bottom = 216
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'TraceLogsLastDay'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'TraceLogsLastDay'
GO




USE [AppLogs]
GO
INSERT [dbo].[TraceLogLevels] ([Id], [Name]) VALUES (1, N'Critical Error      ')
GO
INSERT [dbo].[TraceLogLevels] ([Id], [Name]) VALUES (5, N'Debug               ')
GO
INSERT [dbo].[TraceLogLevels] ([Id], [Name]) VALUES (2, N'Error               ')
GO
INSERT [dbo].[TraceLogLevels] ([Id], [Name]) VALUES (4, N'Info                ')
GO
INSERT [dbo].[TraceLogLevels] ([Id], [Name]) VALUES (3, N'Warning             ')
GO