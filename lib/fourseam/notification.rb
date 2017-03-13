module Fourseam
  class Notification
    attr_accessor :apn, :fcm, :delivery_handler, :delivery_method

    def deliver!
      # inform_interceptors
      response = delivery_method.deliver!(self)
      # inform_observers
      response
    end
  end

  class Apn
    attr_reader :device_token, :payload

    def initialize(payload, device_token)
      @payload, @device_token = payload, device_token
    end
  end

  class Fcm
    attr_reader :payload

    def initialize(payload, *)
      @payload = payload
    end
  end
end
