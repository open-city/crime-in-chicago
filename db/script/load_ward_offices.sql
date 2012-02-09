-- remove first header from CSV before the COPY
TRUNCATE TABLE ward_offices;
COPY ward_offices (
    ward,
    alderman,
    address,
    city,
    state,
    zipcode,
    ward_phone,
    website,
    location)
FROM STDIN
WITH (
    FORMAT csv, 
    HEADER
);
