require "sequel-rails/configuration"

module Rails
  module Sequel

    def self.setup(environment)
      ::Sequel.connect configuration.environment_for environment.to_s
    end

  end
end
