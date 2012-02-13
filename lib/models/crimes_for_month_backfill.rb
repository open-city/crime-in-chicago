require 'yaml'
require 'sequel'

class CrimesForMonthBackfill
  config = YAML.load_file("config/database.yml")
  DB = Sequel.postgres(config[ENV['RACK_ENV'] || 'development'])

  def initialize
    @insert_dataset = DB[:crimes_for_month]
    @rows_inserted = 0
  end

  def run
    ds = DB.fetch(crimes_for_month_sql)
    last_row = {:month => 12}
    ds.each do |row|
    #ds.limit(10_000).each do |row|
      if rows_for_same_ward_type_and_year(row, last_row)
        if row[:month] != last_row[:month] + 1
          add_crimes_for_month_zero_rows(row, ((last_row[:month]+1)...row[:month]))
        end
      else #new year
        if last_row[:month] != 12
          add_crimes_for_month_zero_rows(last_row, ((last_row[:month]+1)..12))
        end
        if row[:month] != 1
          add_crimes_for_month_zero_rows(row, (1...row[:month]))
        end
      end
      last_row = row
    end
  end

  def crimes_for_month_sql
    <<-SQL
      SELECT * 
      FROM crimes_for_month 
      WHERE ward is NOT NULL AND TRIM(ward) NOT IN ('', '0') 
      AND year > 2001 AND year < DATE_PART('year', NOW())
      ORDER BY ward, primary_type, year, month
    SQL
  end

  def rows_for_same_ward_type_and_year(row1, row2)
    row1[:ward] == row2[:ward] && row1[:primary_type] == row2[:primary_type] && row1[:year] == row2[:year]
  end

  def add_crimes_for_month_zero_rows(base_row, month_range)
    month_range.each do |month|
      add_crimes_for_month_zero_row(base_row, month)
    end
  end

  def add_crimes_for_month_zero_row(base_row, month)
    new_row = base_row.merge(:month => month, :crime_count => 0).reject{|k,v| k == :id}
    #puts "- NEW ROW FOR #{new_row.inspect}"
    @insert_dataset.insert(new_row)
    @rows_inserted += 1
    puts "Inserted #{@rows_inserted} rows in crimes_for_month for months with zero crimes" if @rows_inserted % 1000 == 0
  end

end
