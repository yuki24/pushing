# frozen-string-literal: true

module Pushing
  module Adapters
    extend ActiveSupport::Autoload

    autoload :HoustonAdapter, 'pushing/adapters/apn/houston_adapter'
    autoload :ApnoticAdapter, 'pushing/adapters/apn/apnotic_adapter'
    autoload :LowdownAdapter, 'pushing/adapters/apn/lowdown_adapter'
    autoload :AndpushAdapter, 'pushing/adapters/fcm/andpush_adapter'
    autoload :FcmGemAdapter,  'pushing/adapters/fcm/fcm_gem_adapter'
    autoload :TestAdapter

    ADAPTER_INSTANCES = {}

    # Mutex object used to ensure the +instance+ method creates a singleton object.
    MUTEX = Mutex.new

    private_constant :ADAPTER_INSTANCES, :MUTEX

    class << self
      def lookup(name)
        const_get("#{name.to_s.camelize}Adapter")
      end

      ##
      # Provides an adapter instance specified in the +configuration+. If the adapter is not found in
      # +ADAPTER_INSTANCES+, it'll look up the adapter class and create a new instance using the
      # +configuration+.
      def instance(configuration)
        ADAPTER_INSTANCES[configuration.adapter] || MUTEX.synchronize do
          ADAPTER_INSTANCES[configuration.adapter] ||= lookup(configuration.adapter).new(configuration)
        end
      end
    end
  end
end
