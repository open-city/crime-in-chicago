Sequel.migration do
  up do
    run <<-SQL
      ALTER TABLE ward_offices RENAME COLUMN address TO ward_address;
      ALTER TABLE ward_offices RENAME COLUMN city TO ward_city;
      ALTER TABLE ward_offices RENAME COLUMN state TO ward_state;
      ALTER TABLE ward_offices RENAME COLUMN zipcode TO ward_zipcode;
      
      ALTER TABLE ward_offices ADD COLUMN city_hall_address character varying(50);
      ALTER TABLE ward_offices ADD COLUMN city_hall_city character varying(10);
      ALTER TABLE ward_offices ADD COLUMN city_hall_state character varying(2);
      ALTER TABLE ward_offices ADD COLUMN city_hall_zipcode character varying(5);
      ALTER TABLE ward_offices ADD COLUMN city_hall_phone character varying(12);
      ALTER TABLE ward_offices ADD COLUMN email character varying(100);
      ALTER TABLE ward_offices ADD COLUMN image character varying(100);
      
      ALTER TABLE ward_offices DROP COLUMN location RESTRICT;
    SQL
  end

  down do
    run <<-SQL
      ALTER TABLE ward_offices RENAME COLUMN ward_address TO address;
      ALTER TABLE ward_offices RENAME COLUMN ward_city TO city;
      ALTER TABLE ward_offices RENAME COLUMN ward_state TO state;
      ALTER TABLE ward_offices RENAME COLUMN ward_zipcode TO zipcode;
      
      ALTER TABLE ward_offices DROP COLUMN city_hall_address RESTRICT;
      ALTER TABLE ward_offices DROP COLUMN city_hall_city RESTRICT;
      ALTER TABLE ward_offices DROP COLUMN city_hall_state RESTRICT;
      ALTER TABLE ward_offices DROP COLUMN city_hall_zipcode RESTRICT;
      ALTER TABLE ward_offices DROP COLUMN city_hall_phone RESTRICT;
      ALTER TABLE ward_offices DROP COLUMN email RESTRICT;
      ALTER TABLE ward_offices DROP COLUMN image RESTRICT;
      
      ALTER TABLE ward_offices ADD COLUMN location character varying(100);
    SQL
  end
end
