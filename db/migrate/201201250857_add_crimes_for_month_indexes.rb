Sequel.migration do
  up do
    run 'CREATE INDEX crimes_for_month_ward_idx ON crimes_for_month(ward);'
    run 'CREATE INDEX crimes_for_month_year_idx ON crimes_for_month(year);'
  end

  down do
    run 'DROP INDEX crimes_for_month_year_idx;'
    run 'DROP INDEX crimes_for_month_ward_idx;'
  end
end
