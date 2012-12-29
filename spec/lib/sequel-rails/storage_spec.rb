require "spec_helper"

describe Rails::Sequel::Storage do
  let(:environments) do
    {
      "development" => {
        "adapter" => "postgres",
        "owner" => (ENV["TEST_OWNER"] || ENV["USER"]),
        "username" => (ENV["TEST_OWNER"] || ENV["USER"]),
        "database" => "sequel_rails_test_storage_dev",
        "host" => "127.0.0.1",
      },
      "test" => {
        "adapter" => "postgres",
        "owner" => (ENV["TEST_OWNER"] || ENV["USER"]),
        "username" => (ENV["TEST_OWNER"] || ENV["USER"]),
        "database" => "sequel_rails_test_storage_test",
        "host" => "127.0.0.1",
      },
      "production" => {
        "host" => "10.0.0.1",
        "database" => "sequel_rails_test_storage_production",
      },
      "bogus" => {},
    }
  end
  before do
    Rails::Sequel.configuration.stub(:environments).and_return environments
  end
  describe ".create_all" do
    it "creates all databases skipping ones on remote host or with no database name" do
      adapter = mock :storage_adapter
      environments.except("production", "bogus").values.each do |env|
        ::Rails::Sequel::Storage::Postgres.should_receive(:new).
          with(env).
          and_return adapter
      end
      adapter.should_receive(:create).twice
      described_class.create_all
    end
  end
  describe ".drop_all" do
    it "drop all databases skipping ones on remote host or with no database name" do
      adapter = mock :storage_adapter
      environments.except("production", "bogus").values.each do |env|
        ::Rails::Sequel::Storage::Postgres.should_receive(:new).
          with(env).
          and_return adapter
      end
      adapter.should_receive(:drop).twice
      described_class.drop_all
    end
  end
  describe ".create_environment" do
    it "creates database for specified environment" do
      adapter = mock :storage_adapter
      ::Rails::Sequel::Storage::Postgres.should_receive(:new).
        with(environments["development"]).
        and_return adapter
      adapter.should_receive :create
      described_class.create_environment "development"
    end
  end
  describe ".drop_environment" do
    it "drops database for specified environment" do
      adapter = mock :storage_adapter
      ::Rails::Sequel::Storage::Postgres.should_receive(:new).
        with(environments["development"]).
        and_return adapter
      adapter.should_receive :drop
      described_class.drop_environment "development"
    end
  end
  describe ".adapter_for" do
    context "when passed a hash" do
      {
        "postgres" => Rails::Sequel::Storage::Postgres,
        "mysql" => Rails::Sequel::Storage::Mysql,
        "mysql2" => Rails::Sequel::Storage::Mysql2,
        "sqlite" => Rails::Sequel::Storage::Sqlite,
        "jdbc" => Rails::Sequel::Storage::Jdbc,
      }.each do |adapter, klass|
        it "returns an instance of #{klass} when adapter key is #{adapter}" do
          config = {"adapter" => adapter}
          adapter = described_class.adapter_for config
          adapter.should be_instance_of klass
          adapter.config.should be config
        end
      end
      it "raises when adapter is not valid" do
        expect do
          described_class.adapter_for({"adapter" => "unknown"})
        end.to raise_error RuntimeError, "Adapter unknown not supported (:Unknown)"
      end
    end
    context "when passed an environment" do
      it "returns adapter based on configured environment" do
        adapter = described_class.adapter_for :development
        adapter.should be_instance_of Rails::Sequel::Storage::Postgres
        adapter.config.should == environments["development"]
      end
    end
  end
end
