select p.*
from [Logging].PerformanceLogsLastDay p
where p.Timestamp > '02/05/2019 3:50 PM'
order by p.Id asc