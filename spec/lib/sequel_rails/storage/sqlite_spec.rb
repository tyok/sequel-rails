require "spec_helper"

describe SequelRails::Storage::Sqlite, :sqlite do
  let(:config) do
    {
      "adapter" => "sqlite3",
      "database" => database,
    }
  end
  subject { described_class.new config }

  context "when database is not in memory" do
    let(:database) { "test_database.sqlite" }
    let(:database_path) { "#{Combustion::Application.root}/#{database}" }

    describe "#_create" do
      it "defer to Sequel" do
        path = mock :path
        subject.stub(:path).and_return path
        ::Sequel.should_receive(:connect).with("adapter"=>"sqlite3", "database"=>path)
        subject._create
      end
    end

    describe "#_drop" do
      it "delete the database file" do
        path = mock :path, :file? => true
        subject.stub(:path).and_return path
        path.should_receive :unlink
        subject._drop
      end
    end

    describe "#_dump" do
      let(:dump_file_name) { "dump.sql" }
      it "uses the sqlite3 command" do
        subject.should_receive(:`).with(
          "sqlite3 #{database_path} .schema > #{dump_file_name}"
        )
        subject._dump dump_file_name
      end
    end

    describe "#_load" do
      let(:dump_file_name) { "dump.sql" }
      it "uses the sqlite3 command" do
        subject.should_receive(:`).with(
          "sqlite3 #{database_path} < #{dump_file_name}"
        )
        subject._load dump_file_name
      end
    end
  end

  context "when database is in memory" do
    let(:database) { ":memory:" }

    describe "#_create" do
      it "don't do anything" do
        ::Sequel.should_not_receive(:connect)
        subject._create
      end
    end

    describe "#_drop" do
      it "do not try to delete the database file" do
        path = mock :path, :file? => true
        subject.stub(:path).and_return path
        path.should_not_receive :unlink
        subject._drop
      end
    end

    describe "#_dump" do
      it "do not dump anything" do
        subject.should_not_receive(:`)
        subject._dump "dump.sql"
      end
    end

    describe "#_load" do
      it "do not load anything" do
        subject.should_not_receive(:`)
        subject._load "dump.sql"
      end
    end
  end
end
