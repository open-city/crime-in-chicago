require 'ostruct'
require 'yaml'

MY_ENV = ENV['ENV'] || 'development'
CONFIG = OpenStruct.new(YAML.load_file("config/config.yml")[MY_ENV])

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

  desc "download crime data file"
  task :download do |t, args|
    puts "downloading crime file from City of Chicago Data Portal"
    begin
      sh "curl -o tmp/Crimes_-_2001_to_present.csv https://data.cityofchicago.org/api/views/ijzp-q8t2/rows.csv?accessType=DOWNLOAD"
    rescue
      puts "failed to download file"
    end
  end

  desc "ftp postgres dump to public endpoint specified in config.yml"
  task :ftp_postgres_dump do |t, args|
    puts "pushing up to ftp endpoint: #{CONFIG.ftp_url.to_s}"
    require 'net/ftp'
    Net::FTP.open(CONFIG.ftp_url.to_s, CONFIG.ftp_user.to_s, CONFIG.ftp_pass.to_s) do |ftp|
      ftp.chdir(CONFIG.ftp_path.to_s)
      ftp.putbinaryfile('tmp/postgres_backup.dump')
    end
  end

  desc "create local database dump and deploy to production using pgbackups restore"
  task :deploy do |t, args|
    Rake::Task['db:backup:all'].invoke
    Rake::Task['db:ftp_postgres_dump'].invoke
    puts "entering maintenance mode"
    sh "heroku maintenance:on --app crime-in-chicago-cedar"
    puts "restoring database"
    sh "heroku pgbackups:restore HEROKU_POSTGRESQL_VIOLET_URL 'http://#{CONFIG.public_pgdump_path.to_s}/postgres_backup.dump' --app crime-in-chicago-cedar --confirm crime-in-chicago-cedar"
    puts "exiting maintenance mode"
    sh "heroku maintenance:off --app crime-in-chicago-cedar"
    puts "remember to clear the cache!"
  end

  namespace :load do
    desc "download and load crime data file into tables"
    task :crimes do |t, args|
      data_filename = "tmp/Crimes_-_2001_to_present.csv"
      Rake::Task['db:download'].invoke
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
    Rake::Task['db:download'].invoke
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:load:crimes'].invoke
    Rake::Task['db:load:ward_offices'].invoke
    Rake::Task['db:load:crime_types'].invoke
  end
end
