require 'spec_helper'
require 'sequel_rails/db_config'

describe SequelRails::DbConfig do
  let(:root) { '/dummy/project/root' }

  # running under JRuby mangles adapters: tested separately
  context 'when running jruby' do
    before { allow(SequelRails).to receive(:jruby?).and_return true }
    it 'always uses jdbc adapter' do
      expect(from(:adapter => :sqlite)[:adapter]).to eq 'jdbc:sqlite'
    end
    it 'changes postgres adapter to jdbc:postgresql' do
      expect(from(:adapter => :postgres)[:adapter]).to eq 'jdbc:postgresql'
    end
  end

  # and generic handling:
  before { allow(SequelRails).to receive(:jruby?).and_return false }

  def from(definition)
    SequelRails::DbConfig.new definition, :root => root
  end

  it 'normalizes port to an integer' do
    expect(from(:port => '33')[:port]).to eq 33
  end

  it 'normalizes adapter to a string' do
    expect(from(:adapter => :some)[:adapter]).to eq 'some'
  end

  it 'normalizes sqlite3 adapter to sqlite' do
    expect(from(:adapter => :sqlite3)[:adapter]).to eq 'sqlite'
  end

  it 'expands path of an sqlite database' do
    expect(from(:adapter => :sqlite, :database => :some)[:database]).to eq "#{root}/some"
  end

  it "leaves sqlite's :memory: as is" do
    expect(from(:adapter => :sqlite, :database => ':memory:')[:database]).to eq ':memory:'
  end

  it 'normalizes postgresql adapter to postgres' do
    expect(from(:adapter => :postgresql)[:adapter]).to eq 'postgres'
  end

  it 'copies pool to max_connections' do
    expect(from(:pool => 42)[:max_connections]).to eq 42
  end

  it 'works with empty initialization' do
    expect { from({}) }.to_not raise_error
  end

  it 'works when initialized without adapter' do
    expect { from(:database => 'foo') }.to_not raise_error
  end

  it 'does not change the url' do
    url = 'foo://bar/baz'
    expect(from(:adapter => 'jdbc:some', 'url' => url).url).to eq url
  end

  describe '#url' do
    it 'creates plain sqlite URLs' do
      expect(
        from(:adapter => :sqlite, :database => :some).url
      ).to eq "sqlite://#{root}/some"
    end

    it 'creates opaque sqlite URL for memory' do
      expect(
        from(:adapter => :sqlite, :database => ':memory:').url
      ).to eq 'sqlite::memory:'
    end

    it 'creates nice URLs' do
      expect(
        %w(postgres://bar:42/foo?something=hi%21&user=linus
           postgres://bar:42/foo?user=linus&something=hi%21)
      ).to include from(
        :adapter => :postgresql, :database => :foo, :host => 'bar', :port => 42,
        :something => 'hi!', :user => 'linus'
      ).url
    end

    it 'creates triple slash urls when without host' do
      expect(
        from(:adapter => :foo, :database => :bar).url
      ).to eq 'foo:///bar'
    end

    it 'creates proper JDBC URLs' do
      expect(
        %w(jdbc:postgresql://bar:42/foo?something=hi%21&user=linus
           jdbc:postgresql://bar:42/foo?user=linus&something=hi%21)
      ).to include from(
        :adapter => 'jdbc:postgresql', :database => :foo, :host => 'bar',
        :port => 42, :something => 'hi!', :user => 'linus'
      ).url
    end

    it 'creates proper magic Sqlite JDBC URLs' do
      expect(
        from(:adapter => 'jdbc:sqlite', :database => ':memory:').url
      ).to eq 'jdbc:sqlite::memory:'
    end
  end
end
