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

      def dump(filename)
        res = _dump filename
        puts "[sequel] Dumped structure of database '#{database}' to '#{filename}'" if res
        res
      end

      def load(filename)
        res = _load filename
        puts "[sequel] Loaded structure of database '#{database}' from '#{filename}'" if res
        res
      end

      def dump_schema_information(filename, opts={})
        sql = opts.fetch :sql

        res = false
        if File.exists? filename
          res = _dump_schema_information filename, :sql => sql
          puts "[sequel] Dumped current schema information of database '#{database}' to '#{filename}'" if res
        end
        res
      end

      def _dump_schema_information(filename, opts={})
        sql = opts.fetch :sql

        ::File.open(filename, "a") do |file|
          db = ::Sequel.connect config
          migrator = ::Sequel::TimestampMigrator.new db, "db/migrate"

          inserts = migrator.applied_migrations.map do |migration_name|
            insert = migrator.ds.insert_sql(migrator.column => migration_name)
            sql ? insert : "    self << #{insert.inspect}"
          end

          if inserts.any?
            file << "Sequel.migration do\n  change do\n" unless sql
            file << inserts.join("\n")
            file << "\n  end\nend\n" unless sql
          end
        end
      end

      # To be overriden by subclasses
      def close_connections
        true
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
