Sequel.migration do
  up do
    run 'DROP INDEX crimes_per_subcategory_category_idx;'
    run 'CREATE INDEX crimes_per_subcategory_fbi_code_idx ON crimes_per_subcategory(fbi_code);'
      
    run <<-SQL
      ALTER TABLE crimes_for_month DROP COLUMN primary_type RESTRICT;
      ALTER TABLE crimes_per_subcategory DROP COLUMN category RESTRICT;
    SQL
  end

  down do
    run <<-SQL
      ALTER TABLE crimes_for_month ADD COLUMN primary_type character varying(32);
      ALTER TABLE crimes_per_subcategory ADD COLUMN category character varying(32);
    SQL
    
    run 'CREATE INDEX crimes_per_subcategory_category_idx ON crimes_per_subcategory(category);'
    run 'DROP INDEX crimes_per_subcategory_fbi_code_idx;'
  end
end
