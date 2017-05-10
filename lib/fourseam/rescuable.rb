require 'active_support/version'
require 'active_support/rescuable'

module Fourseam #:nodoc:
  module Rescuable
    extend ActiveSupport::Concern
    include ActiveSupport::Rescuable

    class_methods do
      def handle_exception(exception) #:nodoc:
        rescue_with_handler(exception) || raise(exception)
      end
    end

    if ActiveSupport::VERSION::MAJOR > 4
      def handle_exceptions #:nodoc:
        yield
      rescue => exception
        rescue_with_handler(exception) || raise
      end
    else
      def handle_exceptions #:nodoc:
        yield
      end
    end

    private

    def process(*)
      handle_exceptions do
        super
      end
    end
  end
end
