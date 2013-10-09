module SequelRails
  module Storage
    class Sqlite < Abstract
      def _create
        return if in_memory?
        ::Sequel.connect(config.merge('database' => path))
      end

      def _drop
        return if in_memory?
        path.unlink if path.file?
      end

      def _dump(filename)
        return if in_memory?
        escaped_path = SequelRails::Shellwords.shellescape(path.to_s)
        escaped_filename = SequelRails::Shellwords.shellescape(filename)
        exec "sqlite3 #{escaped_path} .schema > #{escaped_filename}"
      end

      def _load(filename)
        return if in_memory?
        escaped_path = SequelRails::Shellwords.shellescape(path.to_s)
        escaped_filename = SequelRails::Shellwords.shellescape(filename)
        exec "sqlite3 #{escaped_path} < #{escaped_filename}"
      end

      private

      def in_memory?
        database == ':memory:'
      end

      def path
        @path ||= Pathname(File.expand_path(database, Rails.root))
      end

    end
  end
end
