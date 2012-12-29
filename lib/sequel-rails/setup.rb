require "sequel-rails/configuration"

module Rails
  module Sequel

    def self.setup(environment)
      conf = configuration.environment_for(environment.to_s).reverse_merge({
        logger: configuration.logger
      })
      ::Sequel.connect conf
    end

  end
end
