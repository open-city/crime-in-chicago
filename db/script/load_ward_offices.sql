-- remove first header from CSV before the COPY
TRUNCATE TABLE ward_offices;
COPY ward_offices (
    ward,
    alderman,
    ward_address,
    ward_city,
    ward_state,
    ward_zipcode,
    ward_phone,
    website,
    city_hall_address,
    city_hall_city,
    city_hall_state,
    city_hall_zipcode,
    city_hall_phone,
    email,
    image)
FROM STDIN
WITH (
    FORMAT csv, 
    HEADER
);
