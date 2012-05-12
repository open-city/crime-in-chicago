TRUNCATE TABLE crimes_for_month;
INSERT INTO crimes_for_month (ward, fbi_code, year, month, crime_count) 
SELECT ward, 
       fbi_code, 
       date_part('year', occurred_at) AS "year", 
       date_part('month', occurred_at) AS "month", 
       count(*) 
FROM crimes
GROUP BY ward, fbi_code, date_part('year', occurred_at), "month" 
ORDER BY ward, fbi_code, year, month
;
