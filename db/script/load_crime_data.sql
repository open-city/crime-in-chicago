-- remove first header from CSV before the COPY
-- > sed 1d Crimes_-_2001_to_present.csv 
TRUNCATE TABLE crimes;
COPY crimes (
    ref_id,
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
    district,
    ward,
    community_area,
    fbi_code,
    x_coordinate,
    y_coordinate,
    year,
    updated_at,
    lat,
    lng,
    location)
FROM STDIN
WITH (
    FORMAT csv, 
    HEADER
);
