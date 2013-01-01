begin
  require 'rspec/core/rake_task'

  desc "Run RSpec code example (default to only PostgreSQL)"
  RSpec::Core::RakeTask.new('spec')

  namespace :spec do
    def clean_env
      [
        "TEST_ADAPTER", 
        "TEST_DATABASE", 
        "TEST_OWNER",
        "TEST_USERNAME",
        "TEST_PASSWORD",
        "TEST_ENCODING",
      ].each do |name|
        ENV[name] = nil
      end
    end

    desc "Run specs for postgresql adapter"
    task :postgresql do
      clean_env
      Rake::Task["spec"].reenable
      ENV["TEST_ADAPTER"] = "postgresql"
      ENV["TEST_ENCODING"] = "unicode"
      Rake::Task["spec"].invoke
    end

    desc "Run specs for mysql adapter"
    task :mysql do
      clean_env
      Rake::Task["spec"].reenable
      ENV["TEST_ADAPTER"] = "mysql"
      ENV["TEST_ENCODING"] = "utf8"
      Rake::Task["spec"].invoke
    end

    desc "Run specs for mysql2 adapter"
    task :mysql2 do
      clean_env
      Rake::Task["spec"].reenable
      ENV["TEST_ADAPTER"] = "mysql2"
      ENV["TEST_ENCODING"] = "utf8"
      Rake::Task["spec"].invoke
    end

    desc "Run specs for sqlite3 adapter"
    task :sqlite3 do
      clean_env
      Rake::Task["spec"].reenable
      ENV["TEST_ADAPTER"] = "sqlite3"
      ENV["TEST_DATABASE"] = ":memory:"
      Rake::Task["spec"].invoke
    end

    desc "Run specs for all adapters"
    task :all do
      Rake::Task["spec:postgresql"].invoke
      Rake::Task["spec:mysql"].invoke
      Rake::Task["spec:mysql2"].invoke
      Rake::Task["spec:sqlite3"].invoke
    end
  end

  task :default => "spec:all"

rescue LoadError
  task :spec do
    abort 'rspec is not available. In order to run spec, you must: bundle install'
  end
end
