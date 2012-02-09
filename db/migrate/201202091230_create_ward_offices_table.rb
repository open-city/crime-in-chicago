Sequel.migration do
  up do
    run <<-SQL
      CREATE TABLE ward_offices (
        id          serial NOT NULL,
        ward        character varying(3),
        alderman    character varying(50),
        address     character varying(50),
        city        character varying(10),
        state       character varying(2),
        zipcode     character varying(5),
        ward_phone  character varying(12),
        website     character varying(100),
        location    character varying(100),

        CONSTRAINT ward_offices_pk PRIMARY KEY(id)
      );
    SQL
  end

  down do
    run 'DROP TABLE ward_offices;'
  end
end
