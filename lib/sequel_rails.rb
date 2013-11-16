require 'sequel_rails/version'
require 'sequel_rails/railtie' if defined? Rails
require 'English'

module SequelRails
  def self.jruby?
    (defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby') || defined?(JRUBY_VERSION)
  end
end
