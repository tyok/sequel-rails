begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks

require 'sequel_rails'

begin
  require 'rspec/core/rake_task'

  desc 'Run RSpec code example (default to only PostgreSQL)'
  RSpec::Core::RakeTask.new

  namespace :spec do
    def clean_env
      %w(
        TEST_ADAPTER
        TEST_DATABASE
        TEST_OWNER
        TEST_USERNAME
        TEST_PASSWORD
        TEST_ENCODING
      ).each do |name|
        ENV[name] = nil
      end
    end

    configs = {
      'postgresql' => { 'TEST_ENCODING' => 'unicode' },
      'mysql'      => { 'TEST_ENCODING' => 'utf8', 'TEST_USERNAME' => 'root' },
      'sqlite3'    => { 'TEST_DATABASE' => 'db/database.sqlite3' },
    }

    configs.merge!('mysql2' => configs.fetch('mysql')) unless SequelRails.jruby?

    configs.each do |adapter, config|
      desc "Run specs for #{adapter} adapter"
      task adapter do
        clean_env
        Rake::Task['spec'].reenable
        ENV['TEST_ADAPTER'] = adapter
        config.each do |key, value|
          ENV[key] = value
        end
        Rake::Task['spec'].invoke
      end
    end

    desc 'Run specs for all adapters'
    task :all do
      configs.keys.map { |adapter| Rake::Task["spec:#{adapter}"].invoke }.all?
    end
  end

  begin
    require 'rubocop/rake_task'

    Rubocop::RakeTask.new do |task|
      task.patterns = ['-R']
    end
  rescue LoadError
    task :rubocop do
      abort 'rubocop is not available. In order to run rubocop, you must: bundle install'
    end
  end

  task :default do
    Rake::Task['spec:all'].invoke
    Rake::Task['rubocop'].invoke if defined?(Rubocop)
  end

rescue LoadError
  task :spec do
    abort 'rspec is not available. In order to run spec, you must: bundle install'
  end
end
