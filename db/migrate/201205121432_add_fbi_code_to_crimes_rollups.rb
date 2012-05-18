Sequel.migration do
  up do
    run <<-SQL
      ALTER TABLE crimes_for_month ADD COLUMN fbi_code character varying(6); 
      ALTER TABLE crimes_per_subcategory ADD COLUMN fbi_code character varying(6);
    SQL
  end

  down do
    run <<-SQL
      ALTER TABLE crimes_for_month DROP COLUMN fbi_code RESTRICT;
      ALTER TABLE crimes_per_subcategory DROP COLUMN fbi_code RESTRICT;
    SQL
  end
end
