require 'rubygems'
require 'bundler'

Bundler.require :default, :development, :test

# Combustion initialization has to happen before loading rspec/rails
Combustion.initialize! :sequel_rails

require 'rspec/rails'
require 'ammeter/init'

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

rspec_exclusions = {}
rspec_exclusions[:skip_jdbc] = SequelRails.jruby?
rspec_exclusions[:postgres] = ENV['TEST_ADAPTER'] != 'postgresql'
rspec_exclusions[:mysql] = !%w(mysql mysql2).include?(ENV['TEST_ADAPTER'])
rspec_exclusions[:sqlite] = ENV['TEST_ADAPTER'] != 'sqlite3'

RSpec.configure do |config|
  config.filter_run_excluding rspec_exclusions
  config.around :each do |example|
    if example.metadata[:no_transaction]
      example.run
    else
      Sequel::Model.db.transaction(:rollback => :always) do
        example.run
      end
    end
  end

  [:expect_with, :mock_with].each do |method|
    config.send(method, :rspec) do |c|
      c.syntax = :expect
    end
  end
end

# Ensure db exists and clean state
begin
  require 'sequel_rails/storage'
  Ammeter::OutputCapturer.capture_stdout do
    SequelRails::Storage.adapter_for(:test).drop
    SequelRails::Storage.adapter_for(:test).create
  end

  require 'sequel/extensions/migration'
  load "#{Rails.root}/db/schema.rb.init"
  Sequel::Migration.descendants.first.apply Sequel::Model.db, :up
rescue Sequel::DatabaseConnectionError => e
  warn "Database connection error: #{e.message}"
  warn 'Ensure test db exists before running specs.'
  exit 1
end
