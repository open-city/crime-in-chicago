Sequel.migration do
  up do
    run <<-SQL
      CREATE TABLE crimes_for_month (
        id           serial NOT NULL,
        ward         character varying(3),
        primary_type character varying(32),
        year	       integer,
        month	       integer,
        crime_count  integer,
  
        CONSTRAINT crimes_for_month_pk PRIMARY KEY(id)
      );
    SQL
  end

  down do
    run 'DROP TABLE crimes_for_month;'
  end
end

