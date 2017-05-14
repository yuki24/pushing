require "active_support/log_subscriber"
require "active_support/core_ext/string/indent"

module Fourseam
  # Implements the ActiveSupport::LogSubscriber for logging notifications when
  # a push notification is delivered.
  class LogSubscriber < ActiveSupport::LogSubscriber
    # A notification was delivered.
    def deliver(event)
      event.payload[:notification].each do |platform, payload|
        info do
          recipients = payload.recipients.map {|r| r.truncate(32) }.join(", ")
          "  #{platform.upcase}: sent push notification to #{recipients} (#{event.duration.round(1)}ms)"
        end

        debug do
          "Payload:\n#{JSON.pretty_generate(payload.payload).indent(2)}\n".indent(2)
        end
      end
    end

    # A notification was generated.
    def process(event)
      debug do
        notifier = event.payload[:notifier]
        action   = event.payload[:action]

        "#{notifier}##{action}: processed outbound push notification in #{event.duration.round(1)}ms"
      end
    end

    # Use the logger configured for Fourseam::Base.
    def logger
      Fourseam::Base.logger
    end
  end
end

Fourseam::LogSubscriber.attach_to :push_notification

