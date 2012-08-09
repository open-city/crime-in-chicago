namespace :cache do
  
  desc 'seed calendar cache'
  task :seed do |t, args|
    (2002..2012).each do |year|
      puts "seeding #{year}"
      (1..50).each do |ward|
        sh "curl -o /dev/null 'http://www.crimeinchicago.org/api/#{year}/wards/#{ward}/crime/calendar'"
        sh "curl -o /dev/null 'http://www.crimeinchicago.org/api/wards/#{ward}/#{year}/statistics/crime.json'"
        sh "curl -o /dev/null 'http://www.crimeinchicago.org/api/wards/#{ward}/#{year}/statistics/category.json'"
        sleep(10) #this is a heavy call - give the db/server a little break
        sh "curl -o /dev/null 'http://www.crimeinchicago.org/api/wards/#{ward}/#{year}/statistics/sparkline.json'"
        sleep(10) #this is a heavy call - give the db/server a little break
      end
    end
  end
end
