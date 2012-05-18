module Crime
  QUERIES = {
    :ward_crime_hash => "
      select ward, count(*) as crime_count
      from crimes
      where
        date_part('year', occurred_at) = :year and
        trim(ward) != ''
      group by ward
      order by ward::integer;".strip,
    :ward_crime_calendar => "
      select cast(occurred_at as date), count(*) as crime_count
      from crimes
      where ward = :ward and date_part('year', occurred_at) = :year
      group by cast(occurred_at as date)
      order by cast(occurred_at as date);".strip,
    :crime_max_daily_year => "
      select ward, occurred_at::date, count(*) max
      from crimes
      where date_part('year', occurred_at) = :year
      group by ward, occurred_at::date
      order by occurred_at::date desc
      limit 1".strip,
    :crime_ward_max_year => "
      select cast(occurred_at as date), count(*) as crime_count, ward
      from crimes
      where date_part('year', occurred_at) = :year
      group by cast(occurred_at as date), ward
      order by crime_count desc limit 1;".strip,
    :ward_crimes_categories_per_year => "
      select count(*) as crime_count, fbi_code
      from crimes
      where ward = :ward and year = :year
      group by fbi_code
      order by crime_count desc
      limit 6".strip,
    :ward_crimes_categories_per_month => "
      select count(*) as crime_count, fbi_code
      from crimes
      where ward = :ward and year = :year and date_part('month', occurred_at) = :month
      group by fbi_code
      order by crime_count desc
      limit 6".strip,
    :ward_crimes_per_year => "
      select cast(date_part('year',occurred_at) as int) as year, count(*) as crime_count_for_year
      from crimes 
      where ward = :ward and date_part('year',occurred_at) > :min_year
      group by date_part('year', occurred_at) 
      order by year;".strip,
    :ward_detail_category_list => "
      select fbi_code, min(crime_count) as minimum, avg(crime_count)::integer as average, 
      max(crime_count) as maximum, sum(crime_count) as total 
      from crimes_for_month 
      where ward = :ward and year > 2002 group by fbi_code;".strip,
    :ward_detail_category_sparkline => "
      select crime_count from crimes_for_month 
      where ward = :ward and year > 2002 and fbi_code = :fbi_code
      order by year, month;".strip,
    :ward_detail_subcategory_list => "
      select subcategory, crime_count from crimes_per_subcategory
      where ward = :ward and fbi_code = :fbi_code
      order by crime_count desc".strip,
    :ward_office => "
      select * from ward_offices
      where ward = :ward".strip,
    :sparkline_by_ward_and_year => "
      select date_part('hour',occurred_at) as hour, count(*) as crime_count from crimes 
      where date_part('year', occurred_at) = :year and ward = :ward 
      group by hour order by hour".strip,
    :category_name_by_fbi_code => "
      select name, legal_definition, friendly_description
      from crime_types
      where fbi_code = :fbi_code".strip
  }
end
