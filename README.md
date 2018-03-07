# Pushing [![Build Status](https://travis-ci.org/yuki24/pushing.svg?branch=master)](https://travis-ci.org/yuki24/pushing)

Pushing is a push notification framework that implements interfaces similar to ActionMailer.

 * **Convention over Configuration**: Pushing brings Convention over Configuration to your app for organizing your push notification implementations.
 * **Extremely Easy to Learn**: If you know how to use ActionMailer, you already know how to use Pushing. Send notifications asynchronously with ActiveJob at no learning cost.
 * **Testability**: First-class support for push notification. No more hassle writing custom code or stubs/mocks for your tests.

**While this gem is actively maintained, it is still under heavy development. It is safe to use it in production, and all public APIs will go through the deprecation cycle (deprecate first and remove). However, expect a large number of changes until it gets stable and mature.**

## Getting Started

Add this line to your application's Gemfile:

```ruby
gem 'pushing'
gem 'jbuilder' # if you don't have it in your Gemfile
```

At the time of writing, Pushing only has support for [jbuilder](https://github.com/rails/jbuilder) (Rails' default JSON constructor), but there are plans to add support for [jb](https://github.com/amatsuda/jb) and [rabl](https://github.com/nesquena/rabl).

### Supported Client Gems

Pushing itself doesn't make HTTP requests. Instead, it uses an adapter to make actual calls. Currently, Pushing has support for the following client gems:

 * [APNs](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/APNSOverview.html#//apple_ref/doc/uid/TP40008194-CH8-SW1):
   * [anpotic](https://github.com/ostinelli/apnotic) (recommended)
   * [lowdown](https://github.com/alloy/lowdown)
   * [houston](https://github.com/nomad/houston)

 * [FCM](https://firebase.google.com/docs/cloud-messaging/):
   * [andpush](https://github.com/yuki24/andpush) (recommended)
   * [fcm](https://github.com/spacialdb/fcm)

If you are starting from scratch, it is recommended using [anpotic](https://github.com/ostinelli/apnotic) for APNs and [andpush](https://github.com/yuki24/andpush) for FCM due to their reliability and performance:

```ruby
gem 'apnotic' # APNs integration
gem 'andpush' # FCM integration
```

### Walkthrough to Writing a Notifier

#### Generate a New Notifier:

```sh
$ rails g pushing:notifier TweetNotifier new_direct_message
```

```ruby
# app/notifiers/tweet_notifier.rb
class TweetNotifier < ApplicationNotifier
  def new_direct_message(message_id, token_id)
    @message = DirectMessage.find(message_id)
    @token   = DeviceToken.find(token_id)

    push apn: @token.apn? && @token.device_token, fcm: @token.fcm?
  end
end
```

#### Edit the Push Notification Payload:

APNs:

```ruby
# app/views/tweet_notifier/new_direct_message.json+apn.jbuilder
json.aps do
  json.alert do
    json.title "#{@tweet.user.display_name} tweeted:"
    json.body truncate(@tweet.body, length: 235)
  end

  json.badge 1
  json.sound 'bingbong.aiff'
end
```

FCM:

```ruby
# app/views/tweet_notifier/new_direct_message.json+fcm.jbuilder
json.to @token.registration_id

json.notification do
  json.title "#{@tweet.user.display_name} tweeted:"
  json.body truncate(@tweet.body, length: 1024)

  json.icon 1
  json.sound 'default'
end
```

### Deliver the Push Notifications:

```ruby
TweetNotifier.new_direct_message(message_id, device_token.id).deliver_now!
# => sends a push notification immediately

TweetNotifier.new_direct_message(message_id, device_token.id).deliver_later!
# => enqueues a job that sends a push notification later
```

## Advanced Usage

### Pushing Only to One Platform

Pushing only sends a notification for the platforms that are given a truthy value. For example, give the following code:

```ruby
push apn: @token.device_token, fcm: false
# => only sends a push notification to APNs

push apn: @token.device_token
# => same as above but without the `:fcm` key, only sends a push notification to APNs
```

This will only send a push notification to APNs and skip the call to FCM.

### APNs

It is often necessary to switch the environment endpoint or adjust the request headers depending on the notification you want to send. Pushing's `#push` method allows for overriding APNs request headers on a delivery-basis:

#### Overriding the default environment:

```ruby
push apn: { device_token: @token.device_token, environment: @token.apn_environment }
```

#### Overriding the default APN topic:

```ruby
push apn: { device_token: @token.device_token, headers: { apns_topic: 'your.otherapp.ios' } }
```

#### Or all of the above:

```ruby
push fcm: @token.fcm?,
     apn: {
       device_token: @token.apn? && @token.device_token,
       environment: @token.apn_environment,
       headers: {
         apns_id:          uuid,
         apns_expiration:  7.days.from_now,
         apns_priority:    5,
         apns_topic:       'your.otherapp.ios',
         apns_collapse_id: 'not-so-important-notification'
       }
     }
```

The `:fcm` key, on the other hand, doesn't have any options as everything's configurable through the request body.

## Error Handling

Like ActionMailer, you can use the `rescue_from` hook to handle exceptions. A common use-case would be to handle a **'BadDeviceToken'** response from APNs or a response with a **'Retry-After'** header from FCM.

**Handling a 'BadDeviceToken' response from APNs**:

```ruby
class ApplicationNotifier < Pushing::Base
  rescue_from Pushing::ApnDeliveryError do |error|
    response = error.response

    if response.status == 410 || (response.status == 400 && response.json[:reason] == 'BadDeviceToken')
      token = error.notification.device_token
      Rails.logger.info("APN device token #{token} has been expired and will be removed.")

      # delete or expire device token accordingly
    else
      raise # Make sure to raise any other types of error to re-enqueue the job
    end
  end
end
```

**Handling a 'Retry-After' header from FCM**:

```ruby
class ApplicationNotifier < Pushing::Base
  rescue_from Pushing::FcmDeliveryError do |error|
    if error.response&.headers['Retry-After']
      # re-enqueue the job honoring the 'Retry-After' header
    else
      raise # Make sure to raise any other types of error to re-enqueue the job
    end
  end
end
```

## Interceptors and Observers

Pushing implements the Interceptor and Observer patterns. A common use-case would be to update registration ids with canonical ids from FCM:

```ruby
# app/observers/fcm_token_handler.rb
class FcmTokenHandler
  def delivered_notification(payload, response)
    return if response.json[:canonical_ids].to_i.zero?

    response.json[:results].select {|result| result[:registration_id] }.each do |result|
      result[:registration_id] # => returns a canonical id

      # Update registration ids accordingly
    end
  end
end

# app/notifiers/application_notifier.rb
class ApplicationNotifier < Pushing::Base
  register_observer FcmTokenHandler.new

  ...
end
```

## Configuration

##### TODO: Make this section more helpful

```ruby
Pushing::Platforms.configure do |config|
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

```

## Testing

Pushing provides first-class support for testing. In order to test your notifier, use the `:test` adapter in the test environment instead of an actual adapter in development/production.

```ruby
# config/initializers/pushing.rb
Pushing::Platforms.configure do |config|
  config.apn.adapter = Rails.env.test? ? :test : :apnotic
  config.fcm.adapter = Rails.env.test? ? :test : :andpush
end
```

Now you can call the `#deliveries` method on the notifier. Here is an example with [ActiveSupport::TestCase](http://api.rubyonrails.org/classes/ActiveSupport/TestCase.html):

```ruby
TweetNotifier.deliveries.clear # => clears the test inbox

assert_changes -> { TweetNotifier.deliveries.apn.size }, from: 0, to: 1 do
  TweetNotifier.new_direct_message(message.id, apn_device_token.id).deliver_now!
end

apn_message = TweetNotifier.deliveries.apn.first
assert_equal 'apn-device-token',  apn_message.device_token
assert_equal "Hey coffee break?", apn_message.payload[:aps][:alert][:body]

assert_changes -> { TweetNotifier.deliveries.fcm.size }, from: 0, to: 1 do
  TweetNotifier.new_direct_message(message.id, fcm_registration_id.id).deliver_now!
end

fcm_payload = TweetNotifier.deliveries.fcm.first.payload
assert_equal 'fcm-registration-id', fcm_payload[:to]
assert_equal "Hey coffee break?",   fcm_payload[:notification][:body]
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yuki24/pushing. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
