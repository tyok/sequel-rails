require "sequel/database/logging"
require "active_support/notifications"

module Sequel
  class Database

    def log_yield(sql, args=nil)
      sql_for_log = args ? "#{sql}; #{args.inspect}" : sql
      start = Time.now
      begin
        ::ActiveSupport::Notifications.instrument(
          "sql.sequel",
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

  end
end
