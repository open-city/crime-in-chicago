begin
  config = YAML.load_file("config/database.yml")
rescue
  # Add logic for production heroku later
  raise "You must create a database.yml"
end

DB = Sequel.postgres(config[Sinatra::Application.environment.to_s].reject { |key, value|
  key == "adapter"
})

