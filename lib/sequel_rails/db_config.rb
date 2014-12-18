require 'active_support/hash_with_indifferent_access.rb'

module SequelRails
  class DbConfig < ActiveSupport::HashWithIndifferentAccess
    def initialize raw, opts = {}
      merge! raw
      self[:port] = port.to_i if include? :port
      normalize_adapter if include? :adapter
      normalize_db opts[:root] if include? :database
      self[:max_connections] = pool if include? :pool
    end

    # allow easier access
    def method_missing key, *a
      return self[key] if a.empty? and include? key
      super
    end

    def url
      self[:url] || make_url.to_s
    end

    private
    ADAPTER_MAPPING = {
      'sqlite3' => 'sqlite',
      'postgresql' => 'postgres'
    }

    def normalize_adapter
      self[:adapter] = ADAPTER_MAPPING[adapter.to_s] || adapter.to_s
      self[:adapter] = jdbcify_adapter if SequelRails.jruby?
    end

    def jdbcify_adapter
       return if adapter =~ /^jdbc:/
       self[:adapter] = 'postgresql' if adapter == 'postgres'
       adapter.prepend 'jdbc:'
    end

    def normalize_db root
      return unless include? :adapter
      if root && adapter.include?('sqlite') && database != ':memory:'
        # sqlite expects path as the database name
        self[:database] = File.expand_path database.to_s, root
      end
    end

    def make_url
      if adapter =~ /^(jdbc|do):/
        scheme, subadapter = adapter.split ':'
        return URI::Generic.build \
            scheme: scheme,
            opaque: build_url(to_hash.merge 'adapter' => subadapter).to_s
      else
        build_url to_hash
      end
    end

    def build_url cfg
      if (adapter = cfg['adapter']) =~ /sqlite/ &&
          (database = cfg['database']) =~ /^:/
        # magic sqlite databases
        return URI::Generic.build \
            scheme: adapter,
            opaque: database
      end

      # these four are handled separately
      params = cfg.reject { |k| %w(adapter host port database).include? k }

      if v = params['search_path']
        # make sure there's no whitespace
        v = v.split(',').map(&:strip) unless v.respond_to? :join
        params['search_path'] = v.join(',')
      end

      path = cfg['database']
      path = path.to_s.dup.prepend('/') if path =~ %r(^(?!/))

      q = URI.encode_www_form(params)
      q = nil if q.empty?

      URI::Generic.build \
          scheme: cfg['adapter'],
          host: cfg['host'],
          port: cfg['port'],
          path: path,
          query: q
    end
  end
end
