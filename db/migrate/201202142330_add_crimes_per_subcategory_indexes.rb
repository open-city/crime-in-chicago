Sequel.migration do
  up do
    run 'CREATE INDEX crimes_per_subcategory_ward_idx ON crimes_per_subcategory(ward);'
    run 'CREATE INDEX crimes_per_subcategory_category_idx ON crimes_per_subcategory(category);'
  end

  down do
    run 'DROP INDEX crimes_per_subcategory_category_idx;'
    run 'DROP INDEX crimes_per_subcategory_ward_idx;'
  end
end
