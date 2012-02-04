require "json"

require "crime/view_helpers"
require "crime/html_helpers"
require "crime/cacheable"
require "crime/application"

module Crime
  QUERIES = {
    :ward_crime_hash => "
      select cast(ward as int) ward, count(*) as crime_count
      from crimes
      where
        date_part('year', occurred_at) = :year and
        ward is not null and
        trim(ward) != '' and ward != '0'
      group by ward
      order by ward;".strip,
    :ward_crime_calendar => "
      select cast(occurred_at as date), count(*) as crime_count
      from crimes
      where ward = :ward and date_part('year', occurred_at) = :year
      group by cast(occurred_at as date)
      order by cast(occurred_at as date);".strip,
    :crime_max_year => "
      select cast(occurred_at as date), count(*) as crime_count, ward
      from crimes
      where date_part('year', occurred_at) = :year
      group by cast(occurred_at as date), ward
      order by crime_count desc limit 1;".strip,
    :ward_crimes_per_year => "
      select cast(date_part('year',occurred_at) as int) as year, count(*) as crime_count_for_year
      from crimes 
      where ward = :ward and date_part('year',occurred_at) > 2001
      group by date_part('year', occurred_at) 
      order by year;".strip
  }
end
