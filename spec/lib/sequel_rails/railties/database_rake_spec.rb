require "spec_helper"

describe "Database rake tasks" do

  let(:app) { Combustion::Application }
  let(:app_root) { app.root }

  describe "db:schema:dump" do
    let(:schema) { "#{app_root}/db/schema.rb" }
    around do |example|
      FileUtils.cp schema, "#{schema}.orig"
      begin
        example.run
      ensure
        FileUtils.mv "#{schema}.orig", schema
      end
    end

    it "dumps the schema in 'db/schema.rb'" do
      Dir.chdir app_root do
        expect{`rake db:schema:dump`}.to change{File.mtime schema}
      end
    end

    it "append the migration schema information if any" do
      Dir.chdir app_root do
        `rake db:migrate`
        `rake db:schema:dump`
        File.read(schema).should include <<-EOS
Sequel.migration do
  change do
    self << "INSERT INTO \\\"schema_migrations\\\" (\\\"filename\\\") VALUES ('1273253849_add_twitter_handle_to_users.rb')"
  end
end
EOS
      end
    end
  end

  describe "db:structure:dump" do
    let(:schema) { "#{app_root}/db/structure.sql" }
    around do |example|
      begin
        example.run
      ensure
        FileUtils.rm schema
      end
    end

    it "dumps the schema in 'db/structure.sql'" do
      Dir.chdir app_root do
        File.exists?(schema).should_not be_true
        `rake db:structure:dump`
        File.exists?(schema).should be_true
      end
    end

    it "append the migration schema information if any" do
      Dir.chdir app_root do
        `rake db:migrate`
        `rake db:structure:dump`

        sql = "INSERT INTO \\\"schema_migrations\\\" (\\\"filename\\\") VALUES ('1273253849_add_twitter_handle_to_users.rb')"
        File.read(schema).should include sql
      end
    end
  end

end
