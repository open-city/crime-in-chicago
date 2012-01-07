require 'bundler'
Bundler.require :default

base = File.dirname(__FILE__)
$:.unshift File.join(base, "lib")

require 'chicago/crime'

Sinatra::Base.set(:root) { base }
run Chicago::Crime::Application

