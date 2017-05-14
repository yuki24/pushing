module Fourseam
  module Platforms
    class FcmPayload
      def initialize(payload, *)
        @payload = payload
      end

      def recipients
        Array(payload[:to]) # TODO: make sure the :to key can hold an array
      end

      # TODO: You shouldn't have to parse the json
      def payload
        JSON.parse(@payload, symbolize_names: true)
      end
    end
  end
end
