require "rubygems"
require "bundler"

Bundler.require :default, :development, :test

# Combustion initialization has to happend before loading rspec/rails
Combustion.initialize! "sequel_rails"

require "rspec/rails"

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.around :each do |example|
    Sequel::Model.db.transaction(rollback: :always) do
      example.run
    end
  end
end

# Ensure db exists and clean state
begin
  require "sequel_rails/storage"
  silence(:stdout) do
    SequelRails::Storage.adapter_for(:test).drop
    SequelRails::Storage.adapter_for(:test).create
  end

  require 'sequel/extensions/migration'
  load "#{Rails.root}/db/schema.rb"
  Sequel::Migration.descendants.first.apply Sequel::Model.db, :up
rescue Sequel::DatabaseConnectionError => e
  puts "Database connection error: #{e.message}"
  puts "Ensure test db exists before running specs."
  exit 1
end
