require 'active_support/core_ext/module/attribute_accessors'

module Fourseam
  class TestNotifier
    cattr_accessor :deliveries
    self.deliveries = []

    def initialize(*); end

    def deliver!(notification)
      self.class.deliveries << notification
    end
  end
end
