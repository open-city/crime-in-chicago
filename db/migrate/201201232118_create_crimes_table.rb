Sequel.migration do
  up do
    run <<-SQL
      CREATE TABLE crimes (
        id           serial NOT NULL,
        case_number  character varying(12),
        occurred_at  timestamp,
        block        character varying(50),
        iucr         character varying(4),
        primary_type character varying(32),
        description  character varying(59),
        location_desc character varying(50),
        arrest       boolean,
        domestic     boolean,
        beat         character varying(4),
        ward         character varying(3),
        fbi_code     character varying(3),
        x_coordinate integer,
        y_coordinate integer,
        year       character varying(4),
        lat          character varying(18),
        lng          character varying(18),
        location     character varying(40),

        CONSTRAINT crimes_pk PRIMARY KEY(id)
      );
    SQL
  end

  down do
    run 'DROP TABLE crimes;'
  end
end
