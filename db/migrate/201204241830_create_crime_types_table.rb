Sequel.migration do
  up do
    run <<-SQL
      CREATE TABLE crime_types (
        id                    serial NOT NULL,
        fbi_code              character varying(4),
        name                  character varying(50),
        legal_definition      text,
        friendly_description  text,

        CONSTRAINT crime_types_pk PRIMARY KEY(id)
      );
      
      CREATE INDEX crimes_fbi_code_idx ON crimes(fbi_code);
    SQL
  end

  down do
    run 'DROP TABLE crime_types;'
  end
end
