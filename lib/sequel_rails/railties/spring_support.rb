module SequelRails
  module SpringSupport
    def disconnect_database_with_sequel
      Sequel::DATABASES.each(&:disconnect) if sequel_configured?
      disconnect_database_without_sequel
    end

    private

    def sequel_configured?
      defined?(Sequel::DATABASES)
    end
  end
end
