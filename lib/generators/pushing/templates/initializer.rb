Pushing.configure do |config|
  # Adapter that is used to send push notifications through FCM
  config.fcm.adapter = Rails.env.test? ? :test : :andpush

  # Your FCM servery key that can be found here: https://console.firebase.google.com/project/_/settings/cloudmessaging
  config.fcm.server_key = 'YOUR_FCM_SERVER_KEY'

  # Adapter that is used to send push notifications through APNs
  config.apn.adapter = Rails.env.test? ? :test : :apnotic

  # The environment that is used by default to send push notifications through APNs
  config.apn.environment = Rails.env.production? ? :production : :development

  # The scheme that is used for negotiating connection trust between your provider
  # servers and Apple Push Notification service. As documented in the offitial doc,
  # there are two schemes available:
  #
  #   :token       - Token-based provider connection trust (default)
  #   :certificate - Certificate-based provider connection trust
  #
  # This option is only applied when using an adapter that uses the HTTP/2-based
  # API.
  config.apn.connection_scheme = :token

  # Path to the certificate or auth key for establishing a connection to APNs.
  #
  # This config is always required.
  config.apn.certificate_path = 'path/to/your/certificate'

  # Password for the certificate specified above if there's any.
  # config.apn.certificate_password = 'passphrase'

  # A 10-character key identifier (kid) key, obtained from your developer account.
  # If you haven't created an Auth Key for your app, create a new one at:
  #   https://developer.apple.com/account/ios/authkey/
  #
  # Required if the +connection_scheme+ is set to +:token+.
  config.apn.key_id = 'DEF123GHIJ'

  # The issuer (iss) registered claim key, whose value is your 10-character Team ID,
  # obtained from your developer account. Your team id could be found at:
  #   https://developer.apple.com/account/#/membership
  #
  # Required if the +connection_scheme+ is set to +:token+.
  config.apn.team_id = 'ABC123DEFG'

  # Header values that are added to every request to APNs. documentation for the
  # headers available can be found here:
  #   https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CommunicatingwithAPNs.html#//apple_ref/doc/uid/TP40008194-CH11-SW13
  config.apn.default_headers = {
    apns_priority:    10,
    apns_topic:       'your.awesomeapp.ios',
    apns_collapse_id: 'wrong.topicname.com'
  }
end
