class NotifierWithRescueHandler < Pushing::Base
  cattr_accessor :last_response_from_apn
  cattr_accessor :last_response_from_fcm

  rescue_from Pushing::ApnDeliveryError do |exception|
    self.class.last_response_from_apn = exception.response
  end

  rescue_from Pushing::FcmDeliveryError do |exception|
    self.class.last_response_from_fcm = exception.response
  end

  def fcm
    push fcm: true
  end

  def apn
    push apn: 'invalid-token'
  end
end
