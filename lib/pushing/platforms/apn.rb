module Pushing
  module Platforms
    class ApnPayload
      attr_reader :payload, :device_token

      def initialize(payload, device_token)
        @payload, @device_token = payload, device_token
      end

      def recipients
        Array(@device_token) # TODO: make sure device tokens can be an array
      end
    end
  end
end
