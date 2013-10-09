require "spec_helper"

describe "Database rake tasks" do

  let(:app) { Combustion::Application }
  let(:app_root) { app.root }

  around do |example|
    begin
      FileUtils.rm schema if File.exists? schema
      example.run
    ensure
      FileUtils.rm schema if File.exists? schema
    end
  end

  describe "db:schema:dump" do
    let(:schema) { "#{app_root}/db/schema.rb" }

    it "dumps the schema in 'db/schema.rb'" do
      Dir.chdir app_root do
        `rake db:schema:dump`
        File.exists?(schema).should be_true
      end
    end

    it "append the migration schema information if any" do
      Dir.chdir app_root do
        `rake db:migrate db:schema:dump`
        sql = Sequel::Model.db.from(:schema_migrations).
          insert_sql(:filename => "1273253849_add_twitter_handle_to_users.rb")
        File.read(schema).should include <<-EOS
Sequel.migration do
  change do
    self << #{sql.inspect}
  end
end
EOS
      end
    end
  end

  describe "db:structure:dump", :skip_jdbc do
    let(:schema) { "#{app_root}/db/structure.sql" }

    it "dumps the schema in 'db/structure.sql'" do
      Dir.chdir app_root do
        `rake db:structure:dump`
        File.exists?(schema).should be_true
      end
    end

    it "append the migration schema information if any" do
      Dir.chdir app_root do
        `rake db:migrate db:structure:dump`

        sql = Sequel::Model.db.from(:schema_migrations).
          insert_sql(:filename => "1273253849_add_twitter_handle_to_users.rb")
        File.read(schema).should include sql
      end
    end
  end

end
