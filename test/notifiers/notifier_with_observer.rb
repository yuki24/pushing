class NotifierWithObserver < Pushing::Base
  class FcmTokenHandler
    cattr_accessor :canonical_ids
    self.canonical_ids = []

    def delivered_notification(payload, response)
      return if response.json[:canonical_ids].to_i.zero?

      response.json[:results].select {|result| result[:registration_id] }.each do |result|
        self.class.canonical_ids << result[:registration_id]
      end
    end
  end

  def weather_update(apn: false, fcm: false)
    push apn: apn && ENV.fetch('APN_TEST_DEVICE_TOKEN'), fcm: fcm
  end
end
