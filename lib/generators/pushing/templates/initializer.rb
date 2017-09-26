Pushing::Platforms.configure do |config|
  # Adapter that is used to send push notifications through FCM
  config.fcm.adapter = Rails.env.test? ? :test : :andpush

  # Your FCM servery key that can be found here: https://console.firebase.google.com/project/_/settings/cloudmessaging
  config.fcm.server_key = 'YOUR_FCM_SERVER_KEY'

  # Adapter that is used to send push notifications through APNs
  config.apn.adapter = Rails.env.test? ? :test : :apnotic

  # The environment that is used by default to send push notifications through APNs
  config.apn.environment = Rails.env.production? ? :production : :development

  # Path to the ecrtificate for establishing a connection to APNs
  config.apn.certificate_path = 'path/to/your/certificate'

  # Password for the certificate specified above if there's any
  config.apn.certificate_password = 'passphrase'

  # Header values that are added to every request to APNs. documentation for this
  # can be found here: https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CommunicatingwithAPNs.html#//apple_ref/doc/uid/TP40008194-CH11-SW13
  config.apn.default_headers = {
    apns_priority:    10,
    apns_topic:       'your.awesomeapp.ios',
    apns_collapse_id: 'wrong.topicname.com'
  }
end
