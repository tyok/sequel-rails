require "spec_helper"

describe SequelRails::Storage do
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
    SequelRails.configuration.stub(:environments).and_return environments
  end
  describe ".create_all" do
    it "creates all databases skipping ones on remote host or with no database name" do
      adapter = mock :storage_adapter
      environments.except("production", "bogus").values.each do |env|
        SequelRails::Storage::Postgres.should_receive(:new).
          with(env).
          and_return adapter
      end
      adapter.should_receive(:create).twice
      capture(:stdout) do
        described_class.create_all
      end
    end
  end
  describe ".drop_all" do
    it "drop all databases skipping ones on remote host or with no database name" do
      adapter = mock :storage_adapter
      environments.except("production", "bogus").values.each do |env|
        SequelRails::Storage::Postgres.should_receive(:new).
          with(env).
          and_return adapter
      end
      adapter.should_receive(:drop).twice
      capture(:stdout) do
        described_class.drop_all
      end
    end
  end
  describe ".create_environment" do
    it "creates database for specified environment" do
      adapter = mock :storage_adapter
      SequelRails::Storage::Postgres.should_receive(:new).
        with(environments["development"]).
        and_return adapter
      adapter.should_receive :create
      described_class.create_environment "development"
    end
  end
  describe ".drop_environment" do
    it "drops database for specified environment" do
      adapter = mock :storage_adapter
      SequelRails::Storage::Postgres.should_receive(:new).
        with(environments["development"]).
        and_return adapter
      adapter.should_receive :drop
      described_class.drop_environment "development"
    end
  end
  describe ".adapter_for" do
    context "when passed a hash" do
      {
        "postgres" => SequelRails::Storage::Postgres,
        "mysql" => SequelRails::Storage::Mysql,
        "mysql2" => SequelRails::Storage::Mysql2,
        "sqlite" => SequelRails::Storage::Sqlite,
        "jdbc" => SequelRails::Storage::Jdbc,
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
        adapter.should be_instance_of SequelRails::Storage::Postgres
        adapter.config.should == environments["development"]
      end
    end
  end
end
