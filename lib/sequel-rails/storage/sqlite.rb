module Rails
  module Sequel
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
end
