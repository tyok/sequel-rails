require "sequel_rails/storage/abstract"
require "sequel_rails/storage/sqlite"
require "sequel_rails/storage/mysql"
require "sequel_rails/storage/mysql2"
require "sequel_rails/storage/postgres"
require "sequel_rails/storage/jdbc"

module SequelRails
  module Storage
    def self.create_all
      with_local_repositories { |config| create_environment(config) }
    end

    def self.drop_all
      with_local_repositories { |config| drop_environment(config) }
    end

    def self.create_environment(config)
      adapter_for(config).create
    end

    def self.drop_environment(config)
      adapter_for(config).drop
    end

    def self.adapter_for(config_or_env)
      config = if config_or_env.kind_of? Hash
                 config_or_env
               else
                 ::SequelRails.configuration.environments[config_or_env.to_s]
               end
      lookup_class(config['adapter']).new config
    end

    private

    def self.with_local_repositories
      ::SequelRails.configuration.environments.each_value do |config|
        next if config['database'].blank?
        if config['host'].blank? || %w[ 127.0.0.1 localhost ].include?(config['host'])
          yield config
        else
          puts "This task only modifies local databases. #{config['database']} is on a remote host."
        end
      end
    end

    def self.lookup_class(adapter)
      klass_name = adapter.camelize.to_sym

      unless self.const_defined?(klass_name)
        raise "Adapter #{adapter} not supported (#{klass_name.inspect})"
      end

      const_get klass_name
    end
  end
end
