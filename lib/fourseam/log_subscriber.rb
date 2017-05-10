require "active_support/log_subscriber"

module Fourseam
  # Implements the ActiveSupport::LogSubscriber for logging notifications when
  # a push notification is delivered.
  class LogSubscriber < ActiveSupport::LogSubscriber
    # A notification was delivered.
    def deliver(event)
      event.payload[:notification].each do |platform, payload|
        info do
          recipients = payload.recipients.join(", ")
          "#{platform}: sent push notification to #{recipients} (#{event.duration.round(1)}ms)"
        end

        debug { payload.payload.to_json }
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

    # Use the logger configured for ActionMailer::Base.
    def logger
      Fourseam::Base.logger
    end
  end
end

Fourseam::LogSubscriber.attach_to :push_notification

