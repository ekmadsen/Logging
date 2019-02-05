select p.*
from [Logging].PerformanceLogsLastDay p
where p.Timestamp > '02/05/2019 9:07 AM'
order by p.Id asc