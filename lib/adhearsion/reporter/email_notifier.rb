# encoding: utf-8

require 'pony'
require 'socket'

module Adhearsion
  class Reporter
    class EmailNotifier
      include Singleton

      def init
        Pony.options = Adhearsion::Reporter.config.email
      end

      def notify(ex)
        Pony.mail({
          subject: email_subject(ex),
          body: exception_text(ex),
          from: hostname
        })
      end

      def self.method_missing(m, *args, &block)
        instance.send m, *args, &block
      end

    private
      def email_subject(exception)
        "[#{app_name}-#{environment}] Exception: #{exception.class} (#{exception.message})"
      end

      def exception_text(exception)
        backtrace = exception.backtrace || ["EMPTY BACKTRACE"]
        "#{app_name} reported an exception at #{Time.now.to_s}" +
        "\n\n#{exception.class} (#{exception.message}):\n" +
        backtrace.join("\n") +
        "\n\n"
      end

      def app_name
        Adhearsion::Reporter.config.app_name
      end

      def environment
        Adhearsion.environment.to_s.upcase
      end

      def hostname
        Socket.gethostname
      end
    end
  end
end
