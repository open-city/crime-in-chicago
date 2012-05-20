-- remove first header from CSV before the COPY
TRUNCATE TABLE crime_types;
COPY crime_types (
    fbi_code,
    name,
    legal_definition,
    friendly_description)
FROM STDIN
WITH (
    FORMAT csv, 
    HEADER
);
