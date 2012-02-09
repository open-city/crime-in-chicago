Sequel.migration do
  up do
    run 'CREATE INDEX ward_offices_ward_idx ON ward_offices(ward);'
  end

  down do
    run 'DROP INDEX ward_offices_ward_idx;'
  end
end
