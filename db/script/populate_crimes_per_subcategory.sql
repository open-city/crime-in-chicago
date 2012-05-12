TRUNCATE TABLE crimes_per_subcategory;
INSERT INTO crimes_per_subcategory (ward, fbi_code, subcategory, crime_count)
SELECT ward,
       fbi_code,
       description,
       count(*)
FROM crimes
WHERE date_part('year', occurred_at) > 2001 AND DATE_PART('year', occurred_at) < DATE_PART('year', NOW())
AND ward is NOT NULL AND TRIM(ward) NOT IN ('', '0')
GROUP BY ward, fbi_code, description
ORDER BY ward, fbi_code, count(*) DESC
;
