class BaseNotifier < Fourseam::Base
  def welcome(hash = {})
    push apn: 'device-token', fcm: true
  end
end

