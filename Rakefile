begin
  require 'bundler'
  Bundler::GemHelper.install_tasks
  FileList['tasks/**/*.rake'].each { |task| import task }
rescue LoadError
  puts 'Bundler or a dependency is not installed, install them with: gem install bundler && bundle install'
end
