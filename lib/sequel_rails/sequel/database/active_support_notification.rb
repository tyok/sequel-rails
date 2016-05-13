require 'sequel/database/logging'
require 'active_support/notifications'

module Sequel
  class Database

    def log_connection_yield(sql, conn, args=nil)
      sql_for_log = "#{connection_info(conn) if conn && log_connection_info}#{sql}#{"; #{args.inspect}" if args}"
      start = Time.now
      begin
        ::ActiveSupport::Notifications.instrument(
          'sql.sequel',
          :sql => sql,
          :name => self.class,
          :binds => args
        ) do
          yield
        end
      rescue => e
        log_exception(e, sql_for_log) unless @loggers.empty?
        raise
      ensure
        log_duration(Time.now - start, sql_for_log) unless e || @loggers.empty?
      end
    end

    def log_yield(sql, args = nil, &block)
      log_connection_yield(sql, nil, args, &block)
    end
  end
end
