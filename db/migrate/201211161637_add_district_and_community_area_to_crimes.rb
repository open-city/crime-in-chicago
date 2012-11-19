Sequel.migration do
  up do
    run <<-SQL
      ALTER TABLE crimes ADD COLUMN district character varying(4);
      ALTER TABLE crimes ADD COLUMN community_area character varying(2);
    SQL
  end

  down do
    run <<-SQL
      ALTER TABLE crimes DROP COLUMN district RESTRICT;
      ALTER TABLE crimes DROP COLUMN community_area RESTRICT;
    SQL
  end
end