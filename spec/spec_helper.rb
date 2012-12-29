require "rubygems"
require "bundler"

Bundler.require :default, :development, :test

# Combustion initialization has to happend before loading rspec/rails
Combustion.initialize! "sequel-rails"

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
  db = Sequel::Model.db
  all_tables = (db.tables-[:schema_info, :schema_migrations]).map{|t| %["#{t}"]}.join ','
  db.run "TRUNCATE TABLE #{all_tables} RESTART IDENTITY" unless all_tables.empty?
rescue Sequel::DatabaseConnectionError => e
  puts "Database connection error: #{e.message}"
  puts "Ensure test db exists before running specs."
  exit 1
end
