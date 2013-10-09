require "rubygems"
require "bundler"

Bundler.require :default, :development, :test

# Combustion initialization has to happend before loading rspec/rails
Combustion.initialize! "sequel_rails"

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

rspec_exclusions = {}
rspec_exclusions[:skip_jdbc] = true if SequelRails.jruby?
rspec_exclusions[:postgres] = true unless ENV["TEST_ADAPTER"]=="postgresql"
rspec_exclusions[:mysql] = true unless ["mysql", "mysql2"].include? ENV["TEST_ADAPTER"]
rspec_exclusions[:sqlite] = true unless ENV["TEST_ADAPTER"]=="sqlite3"

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run_excluding rspec_exclusions
  config.around :each do |example|
    Sequel::Model.db.transaction(:rollback => :always) do
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
  load "#{Rails.root}/db/schema.rb.init"
  Sequel::Migration.descendants.first.apply Sequel::Model.db, :up
rescue Sequel::DatabaseConnectionError => e
  puts "Database connection error: #{e.message}"
  puts "Ensure test db exists before running specs."
  exit 1
end
