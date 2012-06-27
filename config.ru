require 'sprockets'
require 'bundler'
Bundler.require :default

base = File.dirname(__FILE__)
$:.unshift File.join(base, "lib")

require 'crime'

Sinatra::Base.set(:root) { base }
run Crime::Application

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'app/assets/javascripts'
  environment.append_path 'vendor/assets/javascripts'
  environment.append_path 'app/assets/stylesheets'
  environment.append_path 'vendor/assets/stylesheets'
  run environment
end

