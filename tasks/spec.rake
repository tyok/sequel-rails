begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new('spec')

  task :default => :spec

rescue LoadError
  task :spec do
    abort 'rspec is not available. In order to run spec, you must: bundle install'
  end
end

