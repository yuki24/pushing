module Fourseam
  class DeliveryDelegator
    def initialize(platform_settings, *)
      @platform_settings = platform_settings
    end

    def deliver!(notification)
      @platform_settings.each do |platform|
        # TODO: should the entire notification object be passed?
        Adapters.lookup(platform.adapter)
          .new(platform)
          .push!(notification)
      end
    end
  end
end
