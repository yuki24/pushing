module Fourseam
  module PlatformSupport
    class Fcm
      attr_accessor :adapter, :server_key

      def initialize
        @adapter, @server_key = :squeeze, nil
      end
    end
  end
end
