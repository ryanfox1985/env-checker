module EnvChecker
  class Notifier
    class << self
      def log_message(configuration, type, environment, error_message)
        return unless error_message

        message = format_error_message(environment, error_message)
        notify(configuration, type, message)
      end

      def format_error_message(environment, error_message)
        return [] unless error_message

        messages = %w([EnvChecker])
        messages << "[#{environment}]" if environment
        messages << error_message
        messages.join(' ')
      end

      def notify(configuration, type, message)
        notify_slack(configuration, message)
        notify_rollbar(configuration, message)
        notify_email(configuration, message)
        notify_logger(configuration, type, message)
      end

      def notify_rollbar(configuration, message)
        # TODO: implement rollbar
      end

      def notify_email(configuration, message)
        # TODO: implement email
      end

      def notify_slack(configuration, message)
        configuration.slack_notifier &&
          configuration.slack_notifier.ping(message)
      rescue StandardError => e
        notify_logger(configuration, :error, e)
      end

      def notify_logger(configuration, type, message)
        configuration.logger &&
          case type
          when :warning
            configuration.logger.warn(message)
          when :error
            configuration.logger.error(message)
          else
            configuration.logger.info(message)
          end
      end
    end
  end
end
