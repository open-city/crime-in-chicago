namespace :db do
  
  desc 'migrate database schema'
  task :migrate, :version do |t, args|
    version = args[:version]
    sh "sequel -tE -m db/migrate #{version.nil? ? '' : "-M #{version}" } config/database.yml"
  end

  namespace :load do
    desc "load crime data file into tables (uses tmp/Crimes_-_2001_to_present.csv by default)"
    task :crimes, :data_filename do |t, args|
      data_filename = args[:data_filename] || "tmp/Crimes_-_2001_to_present.csv"
      puts "loading crime data from #{data_filename}..."
      sh "sed 1d #{data_filename} | psql --dbname=chicago_crime -c \"$(cat db/script/load_crime_data.sql)\""
      puts "populating crimes_for_month table..."
      sh "psql --dbname=chicago_crime -f db/script/load_crime_for_month_data.sql"
    end
    
    desc "load ward offices file into tables (uses tmp/Ward_Offices.csv by default)"
    task :ward_offices, :data_filename do |t, args|
      data_filename = args[:data_filename] || "tmp/Ward_Offices.csv"
      puts "loading ward office data from #{data_filename}..."
      sh "cat #{data_filename} | psql --dbname=chicago_crime -c \"$(cat db/script/load_ward_offices.sql)\""
    end
  end

  desc "migrate schema and load crime data"
  task :setup_from_scratch, :data_filename do |t, args|
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:load:crimes'].invoke(args[:data_filename])
  end
end
