require 'active_job'

module Pushing
  class DeliveryJob < ActiveJob::Base # :nodoc:
    queue_as { Pushing::Base.deliver_later_queue_name }

    if ActiveSupport::VERSION::MAJOR > 4
      rescue_from StandardError, with: :handle_exception_with_notifier_class
    end

    def perform(notifier, mail_method, delivery_method, *args) #:nodoc:
      notifier.constantize.public_send(mail_method, *args).send(delivery_method)
    end

    private

    def notifier_class
      if notifier = Array(@serialized_arguments).first || Array(arguments).first
        notifier.constantize
      end
    end

    def handle_exception_with_notifier_class(exception)
      if klass = notifier_class
        klass.handle_exception exception
      else
        raise exception
      end
    end
  end
end
