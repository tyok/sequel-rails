begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new('spec')

  task :default => :spec

rescue LoadError
  task :spec do
    abort 'rspec is not available. In order to run spec, you must: bundle install'
  end
end

begin
  namespace :spec do
    desc "Run all specs in spec directory with RCov (excluding plugin specs)"
    RSpec::Core::RakeTask.new(:rcov) do |t|
      t.rcov = true
      t.rcov_opts = lambda do
        IO.readlines("spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
      end
    end
  end
rescue LoadError
  namespace :spec do
    task :rcov do
      abort "rcov is not available. In order to run #{name}, you must: bundle install"
    end
  end
end