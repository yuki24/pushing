class NotifierWithObserver < Pushing::Base
  class FcmTokenHandler
    cattr_accessor :canonical_ids
    self.canonical_ids = []

    # Using an instance method allows for injecting dependencies if needed later.
    def delivered_notification(payload, response)
      # Make sure the response ojbect contains `canonical_ids`
      return if !response.respond_to?(:json) || response.json[:canonical_ids].zero?

      response.json[:results].select {|result| result[:registration_id] }.each do |result|
        self.class.canonical_ids << result[:registration_id]
      end
    end
  end

  register_observer FcmTokenHandler.new

  def weather_update(apn: false, fcm: false)
    push apn: apn && ENV.fetch('APN_TEST_DEVICE_TOKEN'), fcm: fcm
  end
end
