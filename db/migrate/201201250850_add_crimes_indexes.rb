Sequel.migration do
  up do
    run 'CREATE INDEX crimes_year_idx ON crimes((date_part(\'year\', occurred_at)));'
    run 'CREATE INDEX crimes_month_idx ON crimes((date_part(\'month\', occurred_at)));'
    run 'CREATE INDEX crimes_dow_idx ON crimes((date_part(\'dow\', occurred_at)));'
    run 'CREATE INDEX crimes_date_idx ON crimes((date(occurred_at)));'
    run 'CREATE INDEX crimes_ward_idx ON crimes(ward);'
    run 'CREATE INDEX crimes_primary_type_idx ON crimes(primary_type);'
  end

  down do
    run 'DROP INDEX crimes_primary_type_idx;'
    run 'DROP INDEX crimes_ward_idx;'
    run 'DROP INDEX crimes_date_idx;'
    run 'DROP INDEX crimes_dow_idx;'
    run 'DROP INDEX crimes_month_idx;'
    run 'DROP INDEX crimes_year_idx;'
  end
end
