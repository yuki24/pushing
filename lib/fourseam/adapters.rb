require 'fourseam/adapters/fcm/squeeze_adapter'

module Fourseam
  module Adapters
    extend ActiveSupport::Concern

    ADAPTER = "Adapter".freeze
    private_constant :ADAPTER

    class << self
      def lookup(name)
        const_get(name.to_s.camelize << ADAPTER)
      end
    end
  end
end
