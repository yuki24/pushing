# Pushing [![Build Status](https://travis-ci.org/yuki24/pushing.svg?branch=master)](https://travis-ci.org/yuki24/pushing)

Pushing is a push notification framework that implements interfaces similar to ActionMailer's APIs.

 * **Convention over Configuration**: Pushing brings Convention over Configuration to your app's push notification implementation.
 * **Extremely Easy to Learn**: If you know how to use ActionMailer, you already know how to use Pushing. Send notifications asynchronously with ActiveJob at no learning cost.
 * **Testability**: First-class support for push notification. No more hassle writing custom code or stubs/mocks for your tests.

## Getting Started

Add this line to your application's Gemfile:

```ruby
gem 'pushing', github: 'yuki24/pushing'
gem 'jbuilder'
```

As the time of writing, Pushing only has support for [jbuilder](https://github.com/rails/jbuilder) (Rails' default JSON constructor), but there are plans to add support for [jb](https://github.com/amatsuda/jb) and [rabl](https://github.com/nesquena/rabl).

### Supported Client Gems

Pushing itself doesn't make HTTP requests. Instead, it uses an adapter and let an underlaying gem do it. Currently, Pushing has support for the following client gems:

 * [APNs](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/APNSOverview.html#//apple_ref/doc/uid/TP40008194-CH8-SW1):
   * [anpotic](https://github.com/ostinelli/apnotic) (recommended)
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

In this README, we'll use Twitter as an example. Suppose you'd like to send a push notification when a user receives a new direct message from other user. To get started, you can use Pushing's notifier generator:

```sh
$ rails g pushing:notifier TweetNotifier new_direct_message
```

#### Edit the Notifier

Let's say there are `direct_messages` and `device_tokens` tables where we store actual messages and device tokens (a.k.a registration ids in FCM) given by APNs or FCM.

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

Notice that the `:apn` key takes a truthy string value while the `:fcm` key takes a boolean value. Also, Pushing only sends a notification for the platforms that are given a truthy value. For example, the call:

```ruby
# only sends a push notification to FCM
push apn: false, fcm: @token.registration_id
```

will only send a notification to the FCM service.

#### Edit the Push Notification Payload

Next, let's modify the templates to generate JSON that contains message data. Like controllers, you can use all the instance variables initialized in the action.

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

### Deliver the Push Notifications

Finally, send a push notification to the user. You can call the `#deliver_now!` method to immediately send a notification, or the `#deliver_later!` method if you have ActiveJob set up.

```ruby
TweetNotifier.new_direct_message(message_id, device_token.id).deliver_now!
# => sends a push notification immediately

TweetNotifier.new_direct_message(message_id, device_token.id).deliver_later!
# => enqueues a job that sends a push notification later
```

## Error Handling

Like ActionMailer, you can use the `rescue_from` hook to handle exceptions. A common use-case would be to handle a **'BadDeviceToken'** response from APNs or a response with a **'Retry-After'** header from FCM.

**Handling a 'BadDeviceToken' response from APNs**:

```ruby
class ApplicationNotifier < Pushing::Base
  rescue_from Pushing::ApnDeliveryError do |error|
    response = error.response

    if response&.status == '410' || (response&.status == '400' && response&.body['reason'] == 'BadDeviceToken')
      # delete device token accordingly
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

TODO

## Testing

Pushing provides first-class support for testing. In the test environment, use the `:test` adapter instead of an actual adapter you'd like to use in development/production.

```ruby
# config/initializers/pushing.rb
Pushing::Platforms.configure do |config|
  config.apn.adapter = Rails.env.test? ? :test : :apnotic
  config.fcm.adapter = Rails.env.test? ? :test : :andpush
end
```

Now you can use the `#deliveries` method. Here is an example with [ActiveSupport::TestCase](http://api.rubyonrails.org/classes/ActiveSupport/TestCase.html):

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
