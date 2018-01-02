require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/module/delegation'

module Pushing
  module Adapters
    class TestAdapter
      class Deliveries
        include Enumerable

        def initialize
          @deliveries = []
        end

        delegate :each, :empty?, :clear, :<<, :length, :size, to: :@deliveries

        def apn
          select {|delivery| delivery.is_a?(Platforms::ApnPayload) }
        end

        def fcm
          select {|delivery| delivery.is_a?(Platforms::FcmPayload) }
        end
      end

      private_constant :Deliveries
      cattr_accessor :deliveries
      self.deliveries = Deliveries.new

      def initialize(*)
      end

      def push!(notification)
        self.class.deliveries << notification if notification
        notification
      end
    end
  end
end
