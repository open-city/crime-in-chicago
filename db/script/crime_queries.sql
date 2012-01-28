-- Crime count by ward for year.
select ward, count(*) from crimes where date_part('year', occurred_at) = 2011 and trim(ward) != '' group by ward order by ward::integer;

-- Crime count by date for year and ward.
select date(occurred_at), count(*) from crimes where date_part('year', occurred_at) = 2011 and ward = '26' group by date(occurred_at) order by date(occurred_at);

-- Crime count by year for ward.
-- Slower than other because goes across all years.
select date_part('year',occurred_at) as "year", count(*) from crimes where ward = '26' group by date_part('year', occurred_at) order by "year";

-- Crime count by month for year and ward.
select date_part('month',occurred_at) as "month", count(*) from crimes where date_part('year', occurred_at) = 2011 and ward = '26' group by "month" order by "month";

-- Crime count by month for year and month and ward
-- For % comparison to month of previous year
select date_part('month',occurred_at) as "month", count(*) from crimes where date_part('year', occurred_at) = 2011 and date_part('month', occurred_at) = 7 and ward = '26' group by "month" order by "month";

-- Crime count by day of week for year and ward.
select date_part('dow',occurred_at) as "dow", count(*) from crimes where date_part('year', occurred_at) = 2011 and ward = '26' group by "dow" order by "dow";

-- Crime count by day of week for year and day of week and ward
-- For % comparison to day of week of previous year
select date_part('dow',occurred_at) as "dow", count(*) from crimes where date_part('year', occurred_at) = 2011 and date_part('dow', occurred_at) = 3 and ward = '26' group by "dow" order by "dow";

-- Crime count by date for year and month and ward
select date(occurred_at) as "day", count(*) from crimes where date_part('year', occurred_at) = 2011 and date_part('month', occurred_at) = 7 and ward = '26' group by "day" order by "day";

-- Crime count by date for date and ward
-- For % comparison to date of previous year
select date(occurred_at) as "day", count(*) from crimes where date(occurred_at) = '07/11/2011' and ward = '26' group by "day";

-- Crime count by hour for year and ward.
select date_part('hour',occurred_at) as "hour", count(*) from crimes where date_part('year', occurred_at) = 2011 and ward = '26' group by "hour" order by "hour";
-- Crime count by hour for year and month and ward.
select date_part('hour',occurred_at) as "hour", count(*) from crimes where date_part('year', occurred_at) = 2011 and date_part('month', occurred_at) = 7 and ward = '26' group by "hour" order by "hour";
-- Crime count by hour for year and day of week and ward.
select date_part('hour',occurred_at) as "hour", count(*) from crimes where date_part('year', occurred_at) = 2011 and date_part('dow', occurred_at) = 3 and ward = '26' group by "hour" order by "hour";
-- Crime count by hour for date and ward.
select date_part('hour',occurred_at) as "hour", count(*) from crimes where date(occurred_at) = '07/11/2011' and ward = '26' group by "hour" order by "hour";

-- Crime count by type for year and ward limit 5
select primary_type, count(*) from crimes where date_part('year', occurred_at) = 2011 and ward = '26' group by primary_type order by count(*) desc limit 5;
-- Crime count by type for year and month and ward limit 5
select primary_type, count(*) from crimes where date_part('year', occurred_at) = 2011 and date_part('month', occurred_at) = 7 and ward = '26' group by primary_type order by count(*) desc limit 5;
-- Crime count by type for year and day of week and ward limit 5
select primary_type, count(*) from crimes where date_part('year', occurred_at) = 2011 and date_part('dow', occurred_at) = 3 and ward = '26' group by primary_type order by count(*) desc limit 5;
-- Crime count by type for date and ward limit 5
select primary_type, count(*) from crimes where date(occurred_at) = '07/11/2011' and ward = '26' group by primary_type order by count(*) desc limit 5;

-- Crime count by primary_type, year and month for ward
select primary_type, date_part('year', occurred_at) as "year", date_part('month', occurred_at) as month, count(*) from crimes where ward = '26' group by primary_type, date_part('year', occurred_at), "month" order by primary_type, year, month;

-- Crime count by primary_type, year and month for ward
-- For sparklines on ward page
select primary_type, year, month, crime_count from crimes_for_month where ward = '42' and year > 2001 order by primary_type, year, month;

-- Monthly min, monthly avg, monthly max and total crime count by primary type for ward
select primary_type, min(crime_count), avg(crime_count)::integer, max(crime_count), sum(crime_count) from crimes_for_month where ward = '28' and year > 2001 group by primary_type;

-- Database size
SELECT pg_size_pretty(pg_database_size('chicago_crime'));

