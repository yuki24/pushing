module Fourseam
  class Base < AbstractController::Base
    abstract!

    class << self
      def method_missing(method_name, *args)
        if action_methods.include?(method_name.to_s)
          #PushNotificationDelivery.new(self, method_name, *args)
        else
          super
        end
      end
    end
  end
end
