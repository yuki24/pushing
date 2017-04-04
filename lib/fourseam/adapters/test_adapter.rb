require 'active_support/core_ext/module/attribute_accessors'

module Fourseam
  module Adapters
    class TestAdapter
      class Deliveries
        include Enumerable

        def initialize
          @deliveries = []
        end

        delegate :each, :clear, :<<, :length, :size, to: :@deliveries

        def apn
          select {|delivery| delivery.is_a?(PlatformSupport::Apn::Payload) }
        end

        def fcm
          select {|delivery| delivery.is_a?(PlatformSupport::Fcm::Payload) }
        end
      end

      cattr_accessor :deliveries
      self.deliveries = Deliveries.new

      attr_reader :platform

      def initialize(platform_settings)
        @platform = platform_settings.platform
      end

      def push!(notification)
        self.class.deliveries << notification[platform] if notification[platform]
      end
    end
  end
end
