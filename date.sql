-- This T-SQL code generates a list of all dates between a start date and an end date
-- without the use of recursivity, without the use of stored data
-- according to a chosen number of years in the past and future
with
     -- Put here the number of years you want in the past and future
     [Years] as (select 10 as NbYearsPast, 3 as NbYearsFuture),

     -- This will get the first day of the start year, and the last day of the end year
     [Limits] as (select
          dateadd(yy, datediff(yy, 0, getdate())-NbYearsPast,-1) as StartDate,
          dateadd(yy, datediff(yy, 0, getdate())+NbYearsFuture,-1) as EndDate
     from [Years]),

     -- This will make a dummy table of 10 values
     [x] as (select n from (values (0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) t(n)),

     -- This will cross join 4 times the dummy table x in order to get 10*10*10*10 = 10000 rows,
     -- if you need more than 10000 dates (i.e. roughly more than 27 years), just add more cross joins
     [list] as (select row_number() over (order by (select null)) as n from x [1s], x [10s], x [100s], x [1000s]),

     -- This will filter out the [list] according to the start and end date
     [range] as (select * from [list] cross join [Limits] l where n < datediff(day,l.StartDate,l.EndDate)),

     -- This will add the number on the row to the start date
     [Dates] as (select dateadd(day,r.n,l.StartDate) as [Date] from [range] r cross join [Limits] l)

select
     [Date],
     datepart(yy,[Date]) as [Year],
     datepart(q,[Date]) as [Quarter],
     datepart(m,[Date]) as [Month],
     datepart(ww,[Date]) as [Week],
     datepart(w,[Date]) as [DayOfWeek],
     datepart(dy,[Date]) as [DayOfYear]
from
     [Dates]
