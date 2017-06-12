# Pushing [![Build Status](https://travis-ci.org/yuki24/pushing.svg?branch=master)](https://travis-ci.org/yuki24/pushing)

**This gem is currently in beta.**

Pushing is a push notification framework that implements interfaces similar to ActionMailer's APIs.

 * **Convention over Configuration**: Pushing brings Convention over Configuration to your app's push notification implementation
 * **Extremely Easy to Learn**: You can get started in 5 minutes if you have used ActionMailer
 * **Testability**: Pushing provides first-class support for testing

## Getting Started

Add this line to your application's Gemfile:

```ruby
gem 'pushing'
gem 'jbuilder'
```

As the time of writing, Pushing only provides support for [jbuilder](https://github.com/rails/jbuilder) (Rails' default JSON constructor), but there are plans to add support for [jq](https://github.com/amatsuda/jb) and [rabl](https://github.com/nesquena/rabl).

### Supported Client Gems

Pushing itself doesn't make HTTP requests. Instead, it uses an adapter and let an underlaying gem do it. Currently, Pushing has support for the following client gems:

 * [APNs](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/APNSOverview.html#//apple_ref/doc/uid/TP40008194-CH8-SW1):
   * [anpotic](https://github.com/ostinelli/apnotic) (recommended)
   * [houston](https://github.com/nomad/houston)

 * [FCM](https://firebase.google.com/docs/cloud-messaging/):
   * [andpush](https://github.com/yuki24/andpush) (recommended)
   * [fcm](https://github.com/spacialdb/fcm)

If you are starting from scratch, we'd recommend using [anpotic](https://github.com/ostinelli/apnotic) for APNs and [andpush](https://github.com/yuki24/andpush) for FCM due to their reliability and performance:

```ruby
gem 'apnotic' # APNs integration
gem 'andpush' # FCM integration
```

### Walkthrough to Writing a Notifier

In this README, we'll use Twitter as an example. Suppose you'd like to send a push notification when a user receives a new direct message from other user.

#### Generate a Notifier

To get started, you can use Pushing's notifier generator:

```sh
$ rails g pushing:notifier TweetNotifier new_direct_message
  create  app/notifiers/tweet_notifier.rb
  create  app/views/tweet_notifier/new_direct_message.json+apn.jbuilder
  create  app/views/tweet_notifier/new_direct_message.json+fcm.jbuilder
  create  app/notifiers/application_notifier.rb
  create  config/initializers/pushing.rb
```

As you can see, you can generate notifiers just like you use other generators with Rails. Notifiers are conceptually similar to controllers, and so we get a mailer and a directory for views.

#### Edit the Notifier

Now it's time to retrieve data from your DB. Let's say there are `direct_messages` and `device_tokens` tables where we store actual messages and device tokens (a.k.a registration ids) given by APNs or FCM.

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

Notice that the `:apn` key takes a truthy string value while the `:fcm` key takes a boolean value. Also, Pushing only sends a notification for the platforms that are given a truthy value. For example, the call `push apn: false, fcm: @token.registration_id` only tries to send a notification to the FCM service.

#### Edit the Push Notification Payload

Next, let's modify the templates to generate JSON that contains message data. Like controllers, you can use all the instance variables initialized in the action:

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

Finally, actually send a push notification to the user. You can call the `#deliver_now!` method to immediately send a notification, or the `#deliver_later!` method if you have ActiveJob set up.

```ruby
TweetNotifier.new_direct_message(message_id, device_token.id).deliver_now!
# => sends a push notification immediately

TweetNotifier.new_direct_message(message_id, device_token.id).deliver_later!
# => enqueues a job that sends a push notification later
```

## Error Handling

Like ActionMailer, you can use the `rescue_from` hook to handle exceptions. A typical use-case would be to handle a **BadDeviceToken** response from APNs or a Timeout response from FCM.

**Handling a BadDeviceToken response from APNs**:

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

**Handling a Timeout response from FCM**:

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

Pushing implements the Interceptor and Observer patterns. A typical usecase would be to update registration ids with canonical ids from FCM:

```ruby
# app/observers/fcm_token_handler.rb
class FcmTokenHandler
  def delivered_notification(payload, response)
    return if response.json[:canonical_ids].to_i.zero?

    response.json[:results].select {|result| result[:registration_id] }.each do |result|
      result[:registration_id] # => returns a canonical id

      # Update registration tokens accordingly
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
setup do
  @friend, @user = User.find(...), User.find(...)
  TweetNotifier.deliveries.clear
end

test "delivers a push notification with a direct message body" do
  apn_device_token    = DeviceToken.create!(device_token: 'apn-device-token',    platform: :apn)
  fcm_registration_id = DeviceToken.create!(device_token: 'fcm-registration-id', platform: :fcm)
  message             = DirectMessage.create!(from: @friend, to: @user, body: "Hey coffee break?")

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
end
```

And with RSpec:

```ruby
let(:apn_device_token)    { DeviceToken.create!(device_token: 'apn-device-token',    platform: :apn) }
let(:fcm_registration_id) { DeviceToken.create!(device_token: 'fcm-registration-id', platform: :fcm) }
let(:message)             { DirectMessage.create!(from: friend, to: user, body: "Hey coffee break?") }

before { TweetNotifier.deliveries.clear }

it "delivers a push notification with a message body to APNs" do
  expect {
    TweetNotifier.new_direct_message(message.id, apn_device_token.id).deliver_now!
  }.to change { TweetNotifier.deliveries.apn.size }.by(1)

  apn_message = TweetNotifier.deliveries.apn.first
  expect(apn_message.device_token).to equal('apn-device-token')
  expect(apn_message.payload[:aps][:alert][:body]).to equal("Hey coffee break?")
end

it "delivers a push notification with a message body to FCM" do
  expect {
    TweetNotifier.new_direct_message(message.id, fcm_registration_id.id).deliver_now!
  }.to change { TweetNotifier.deliveries.fcm.size }.by(1)

  fcm_payload = TweetNotifier.deliveries.fcm.first.payload
  expect(fcm_payload[:to]).to equal('fcm-registration-id')
  expect(fcm_payload[:notification][:body]).to equal("Hey coffee break?")
end
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yuki24/pushing. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
