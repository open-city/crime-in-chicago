-- remove first header from CSV before the COPY
-- > sed 1d Crimes_-_2001_to_present.csv 
TRUNCATE TABLE crimes;
COPY crimes (
    case_number,
    occurred_at,
    block,
    iucr,
    primary_type,
    description,
    location_desc,
    arrest,
    domestic,
    beat,
    ward,
    fbi_code,
    x_coordinate,
    y_coordinate,
    year,
    lat,
    lng,
    location)
FROM STDIN
WITH (
    FORMAT csv, 
    HEADER
);
