namespace :db do
  
  desc 'drop database'
  task :drop do |t, args|
    sh "dropdb chicago_crime"
  end

  desc 'create database'
  task :create do |t, args|
    sh "createdb chicago_crime"
  end

  desc 'migrate database schema'
  task :migrate, :version do |t, args|
    version = args[:version]
    sh "sequel -tE -m db/migrate #{version.nil? ? '' : "-M #{version}" } config/database.yml"
  end

  namespace :backup do
    desc "backup the whole database"
    task :all do |t, args|
      data_filename = args[:data_filename] || "tmp/postgres_backup.dump"
      puts "backing up the database \"chicago_crime\" to #{data_filename}"
      sh "pg_dump -Fc --no-acl --no-owner -h localhost chicago_crime > #{data_filename}"
    end
  end

  namespace :load do
    desc "load crime data file into tables (uses tmp/Crimes_-_2001_to_present.csv by default)"
    task :crimes, :data_filename do |t, args|
      data_filename = args[:data_filename] || "tmp/Crimes_-_2001_to_present.csv"
      puts "loading crime data from #{data_filename}..."
      sh "sed 1d #{data_filename} | psql --dbname=chicago_crime -c \"$(cat db/script/load_crime_data.sql)\""
      Rake::Task['db:load:crimes_for_month'].invoke
      Rake::Task['db:load:crimes_per_subcategory'].invoke
      Rake::Task['db:load:zero_crime_months'].invoke
    end
    
    desc "populate crimes_for_month table"
    task :crimes_for_month do
      puts "populating crimes_for_month table..."
      sh "psql --dbname=chicago_crime -f db/script/load_crime_for_month_data.sql"
      Rake::Task['db:load:zero_crime_months'].invoke
    end

    desc "backfill crimes_for_month table with zero crime months"
    task :zero_crime_months do
      require './lib/models/crimes_for_month_backfill.rb'
      puts "populating crimes_for_month table with zero crime months"
      CrimesForMonthBackfill.new.run
    end

    desc "populate crimes_per_subcategory table"
    task :crimes_per_subcategory do
      puts "populating crimes_per_subcategory table..."
      sh "psql --dbname=chicago_crime -f db/script/populate_crimes_per_subcategory.sql"
    end

    desc "load ward offices file into tables (uses tmp/Ward_Offices.csv by default)"
    task :ward_offices, :data_filename do |t, args|
      data_filename = args[:data_filename] || "db/import/Ward_Offices.csv"
      puts "loading ward office data from #{data_filename}..."
      sh "cat #{data_filename} | psql --dbname=chicago_crime -c \"$(cat db/script/load_ward_offices.sql)\""
    end
    
    desc "load crime types (uses tmp/Crime_Types.csv by default)"
    task :crime_types, :data_filename do |t, args|
      data_filename = args[:data_filename] || "db/import/Crime_Types.csv"
      puts "loading crime types data from #{data_filename}..."
      sh "cat #{data_filename} | psql --dbname=chicago_crime -c \"$(cat db/script/load_crime_types.sql)\""
    end
  end

  desc "create database, migrate schema and load data from csv"
  task :setup_from_scratch do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:load:crimes'].invoke
    Rake::Task['db:load:ward_offices'].invoke
    Rake::Task['db:load:crime_types'].invoke
  end
end
