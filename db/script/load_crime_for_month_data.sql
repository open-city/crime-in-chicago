TRUNCATE TABLE crimes_for_month;
INSERT INTO crimes_for_month (ward, primary_type, year, month, crime_count) 
SELECT ward, 
       primary_type, 
       date_part('year', occurred_at) AS "year", 
       date_part('month', occurred_at) AS "month", 
       count(*) 
FROM crimes
GROUP BY ward, primary_type, date_part('year', occurred_at), "month" 
ORDER BY ward, primary_type, year, month
;
