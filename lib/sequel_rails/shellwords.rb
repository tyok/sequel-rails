module SequelRails
  begin
    require 'shellwords'
    Shellwords = ::Shellwords
  rescue LoadError
    # Taken from shellwords.rb (Ruby 2.0.0p247)
    class Shellwords
      def self.shellescape(str)
        str = str.to_s

        # An empty argument will be skipped, so return empty quotes.
        return "''" if str.empty?

        str = str.dup

        # Treat multibyte characters as is.  It is caller's responsibility
        # to encode the string in the right encoding for the shell
        # environment.
        str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/, '\\\\\\1')

        # A LF cannot be escaped with a backslash because a backslash + LF
        # combo is regarded as line continuation and simply ignored.
        str.gsub!(/\n/, "'\n'")

        str
      end

      def self.shelljoin(array)
        array.map { |arg| shellescape(arg) }.join(' ')
      end
    end
  end
end
