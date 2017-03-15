module Fourseam
  module PlatformSupport
    class Fcm
      attr_accessor :adapter, :server_key

      def initialize
        @adapter, @server_key = :robo_msg, nil
      end
    end
  end
end
