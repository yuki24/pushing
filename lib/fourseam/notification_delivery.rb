require "delegate"

module Fourseam
  class NotificationDelivery < Delegator
    def initialize(notifier_class, action, *args) #:nodoc:
      @notifier_class, @action, @args = notifier_class, action, args

      # The notification is only processed if we try to call any methods on it.
      # Typical usage will leave it unloaded and call deliver_later.
      @processed_notifier = nil
    end

    def __getobj__ #:nodoc:
      @notification_message ||= processed_notifier.notification
    end

    private

    def processed_notifier
      @processed_notifier ||= @notifier_class.new.tap do |notifier|
        notifier.process @action, *@args
      end
    end
  end
end
