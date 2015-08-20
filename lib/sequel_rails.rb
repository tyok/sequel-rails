require 'sequel_rails/version'
require 'sequel_rails/railtie' if defined? Rails
require 'English'

module SequelRails
  def self.jruby?
    (defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby') || defined?(JRUBY_VERSION)
  end

  if Hash.public_instance_methods.include? :deep_symbolize_keys
    def self.deep_symbolize_keys(hash)
      hash.deep_symbolize_keys
    end
  else
    def self.deep_symbolize_keys(hash)
      h = {}
      hash.each { |key, value| h[key.to_sym] = deep_symbolize_keys_map(value) }
      h
    end

    def self.deep_symbolize_keys_map(value)
      case value
      when Hash
        deep_symbolize_keys(value)
      when Array
        value.map { |v| deep_symbolize_keys_map(v) }
      else
        value
      end
    end
  end
end
