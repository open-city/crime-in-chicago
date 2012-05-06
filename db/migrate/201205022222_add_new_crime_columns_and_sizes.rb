Sequel.migration do
  up do
    run <<-SQL
      ALTER TABLE crimes ADD COLUMN ref_id integer NOT NULL;
      ALTER TABLE crimes ADD COLUMN updated_at timestamp;

      ALTER TABLE crimes ALTER COLUMN iucr TYPE character varying(6);
      ALTER TABLE crimes ALTER COLUMN fbi_code TYPE character varying(6);
    SQL
  end

  down do
    run <<-SQL
      ALTER TABLE crimes DROP COLUMN ref_id RESTRICT;
      ALTER TABLE crimes DROP COLUMN updated_at RESTRICT;

      ALTER TABLE crimes ALTER COLUMN iucr TYPE character varying(4);
      ALTER TABLE crimes ALTER COLUMN fbi_code TYPE character varying(3);
    SQL
  end
end
