require "delegate"

module Fourseam
  class NotificationDelivery < Delegator
    def initialize(notifier_class, action, *args) #:nodoc:
      @notifier_class, @action, @args = notifier_class, action, args

      # The notification is only processed if we try to call any methods on it.
      # Typical usage will leave it unloaded and call deliver_later.
      @processed_notifier = nil
      @notification_message = nil
    end

    def __getobj__ #:nodoc:
      @notification_message ||= processed_notifier.notification
    end

    # Unused except for delegator internals (dup, marshaling).
    def __setobj__(notification_message) #:nodoc:
      @notification_message = notification_message
    end

    def message
      __getobj__
    end

    def processed?
      @processed_notifier || @notification_message
    end

    def deliver_later!(options = {})
      enqueue_delivery :deliver_now!, options
    end

    def deliver_now!
      processed_notifier.handle_exceptions do
        # inform_interceptors
        response = delivery_method.deliver!(message)
        # inform_observers
        response
      end
    end

    private

    def delivery_method
      @delivery_method ||= begin
        method = @notifier_class.delivery_method

        case method
        when NilClass
          raise "Delivery method cannot be nil"
        when Symbol
          if klass = @notifier_class.delivery_methods[method]
            platform_settings = @notifier_class.platforms.map do |platform|
              @notifier_class.public_send(platform)
            end

            method = klass.new(platform_settings, (@notifier_class.send(:"#{method}_settings") || {}))
          else
            raise "Invalid delivery method #{method.inspect}"
          end
        end

        method
      end
    end

    def delivery_handler
      @delivery_handler ||= @notifier_class
    end

    def processed_notifier
      @processed_notifier ||= @notifier_class.new.tap do |notifier|
        notifier.process @action, *@args
      end
    end

    def enqueue_delivery(delivery_method, options = {})
      if processed?
        ::Kernel.raise "You've accessed the message before asking to " \
                       "deliver it later, so you may have made local changes that would " \
                       "be silently lost if we enqueued a job to deliver it. Why? Only " \
                       "the notifier method *arguments* are passed with the delivery job! " \
                       "Do not access the message in any way if you mean to deliver it " \
                       "later. Workarounds: 1. don't touch the message before calling " \
                       "#deliver_later, 2. only touch the message *within your notifier " \
                       "method*, or 3. use a custom Active Job instead of #deliver_later."
      else
        args = @notifier_class.name, @action.to_s, delivery_method.to_s, *@args
        ::Fourseam::DeliveryJob.set(options).perform_later(*args)
      end
    end
  end
end
