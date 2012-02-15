Sequel.migration do
  up do
    run <<-SQL
      CREATE TABLE crimes_per_subcategory (
        id           serial NOT NULL,
        ward         character varying(3),
        category     character varying(32),
        subcategory  character varying(59),
        crime_count  integer,
  
        CONSTRAINT crimes_per_subcategory_pk PRIMARY KEY(id)
      );
    SQL
  end

  down do
    run 'DROP TABLE crimes_per_subcategory;'
  end
end

