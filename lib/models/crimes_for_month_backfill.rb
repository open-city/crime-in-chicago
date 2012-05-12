require 'yaml'
require 'sequel'

class CrimesForMonthBackfill
  config = YAML.load_file("config/database.yml")
  DB = Sequel.postgres(config[ENV['RACK_ENV'] || 'development'])

  def initialize
    @insert_dataset = DB[:crimes_for_month]
    @rows_inserted = 0
  end

  def crimes_for_month_sql
    <<-SQL
      SELECT * 
      FROM crimes_for_month 
      WHERE ward is NOT NULL AND TRIM(ward) NOT IN ('', '0') 
      AND year > 2001 AND year < DATE_PART('year', NOW())
      ORDER BY ward, fbi_code, year, month
    SQL
  end

  def run
    ds = DB.fetch(crimes_for_month_sql)
    last_row = {:year => 2011, :month => 12}
    ds.each do |row|
      if !rows_for_same_ward_and_category(row, last_row)
        # new category
        add_missing_months_at_end_of_previous_year(last_row)
        add_missing_years_at_end_of_previous_category(last_row)
        add_missing_years_at_beginning_of_new_category(row)
        add_missing_months_at_beginning_of_new_year(row)
      else 
        # same category
        if row[:year] != last_row[:year]
          #new year
          add_missing_months_at_end_of_previous_year(last_row)
          add_missing_months_between_previous_and_new_years(last_row, row)
          add_missing_months_at_beginning_of_new_year(row)
        else #same year
          add_missing_months_between_previous_and_new_months(last_row, row)
        end
      end
      #puts row.inspect
      last_row = row
    end
    add_missing_months_at_end_of_previous_year(last_row)
    add_missing_years_at_end_of_previous_category(last_row)
  end

  def add_missing_years_at_end_of_previous_category(last_row)
    if last_row[:year] != Time.now.year-1
      add_zero_crimes_rows_for_years(last_row, ((last_row[:year]+1)...Time.now.year))
    end
  end

  def add_missing_years_at_beginning_of_new_category(current_row)
    if current_row[:year] != 2002
      add_zero_crimes_rows_for_years(current_row, (2002...current_row[:year]))
    end
  end

  def add_missing_months_at_end_of_previous_year(last_row)
    if last_row[:month] != 12
      add_zero_crimes_rows(last_row, ((last_row[:month]+1)..12))
    end
  end

  def add_missing_months_between_previous_and_new_years(last_row, current_row)
    if current_row[:year] != last_row[:year] + 1
      add_zero_crimes_rows_for_years(current_row, ((last_row[:year]+1)...current_row[:year]))
    end
  end

  def add_missing_months_at_beginning_of_new_year(current_row)
    if current_row[:month] != 1
      add_zero_crimes_rows(current_row, (1...current_row[:month]))
    end
  end

  def add_missing_months_between_previous_and_new_months(last_row, current_row)
    if current_row[:month] != last_row[:month] + 1
      add_zero_crimes_rows(current_row, ((last_row[:month]+1)...current_row[:month]))
    end
  end

  def rows_for_same_ward_and_category(row1, row2)
    row1[:ward] == row2[:ward] && row1[:fbi_code] == row2[:fbi_code]
  end

  def add_zero_crimes_rows_for_years(base_row, year_range)
    year_range.each do |year|
      add_zero_crimes_rows(base_row.merge(:year => year), (1..12))
    end
  end

  def add_zero_crimes_rows(base_row, month_range)
    month_range.each do |month|
      add_zero_crimes_row(base_row, month)
    end
  end

  def add_zero_crimes_row(base_row, month)
    new_row = base_row.merge(:month => month, :crime_count => 0).reject{|k,v| k == :id}
    #puts "NEW ROW: #{new_row.inspect}"
    @insert_dataset.insert(new_row)
    @rows_inserted += 1
    puts "Inserted #{@rows_inserted} rows in crimes_for_month for months with zero crimes" if @rows_inserted % 1000 == 0
  end

end
