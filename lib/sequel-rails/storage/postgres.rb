module Rails
  module Sequel
    module Storage
      class Postgres < Abstract
        def _create
          ENV["PGPASSWORD"] = password unless password.blank?
          commands = ["createdb", "--encoding", charset]
          commands << "--username" << username unless username.blank?
          commands << "--owner" << owner unless owner.blank?
          commands << "--port" << port unless port.blank?
          commands << "--host" << host unless host.blank?
          commands << database
          res = system(*commands)
          ENV["PGPASSWORD"] = nil
          res
        end

        def _drop
          system("dropdb", "-U", username, database)
        end
      end
    end
  end
end
