module SequelRails
  module Storage
    class Abstract

      attr_reader :config

      def initialize(config)
        @config = config
      end

      def create
        res = _create
        puts "[sequel] Created database '#{database}'" if res
        res
      end

      def drop
        ::Sequel::Model.db.disconnect
        res = _drop
        puts "[sequel] Dropped database '#{database}'" if res
        res
      end

      def database
        @database ||= config['database'] || config['path']
      end

      def username
        @username ||= config['username'] || config['user'] || ''
      end

      def password
        @password ||= config['password'] || ''
      end

      def host
        @host ||= config['host'] || ''
      end

      def port
        @port ||= config['port'] || ''
      end

      def owner
        @owner ||= config['owner'] || ''
      end

      def charset
        @charset ||= config['charset'] || ENV['CHARSET'] || 'utf8'
      end

    end
  end
end
