# Pushing

**This gem is currently in alpha.**

Pushing is a push notification framework that implements similar interfaces to ActionMailer's APIs.

## Philosophy

 * **Convention over Configuration**
 * **DRY**
 * **Testability**

## Getting Started

Add this line to your application's Gemfile:

```ruby
gem 'pushing'
```

### Supported Client Gems

 * APN:
   * [anpotic](https://github.com/ostinelli/apnotic) (recommended)
   * [houston](https://github.com/nomad/houston)

 * FCM:
   * [andpush](https://github.com/yuki24/andpush) (recommended)

```ruby
gem 'apnotic' # APNs integration
gem 'andpush' # FCM integration
```

### Walkthrough to Generating a Notifier

#### Generate a Notifier

```sh
$ rails g pushing:notifier TweetNotifier new_direct_message
  create  app/notifiers/tweet_notifier.rb
  create  app/views/tweet_notifier/new_direct_message.json+apn.jbuilder
  create  app/views/tweet_notifier/new_direct_message.json+fcm.jbuilder
  create  app/notifiers/application_notifier.rb
  create  config/initializers/pushing.rb
```

```ruby
# app/notifiers/application_notifier.rb
class ApplicationNotifier < Pushing::Base
end

# app/notifiers/tweet_notifier.rb
class TweetNotifier < ApplicationNotifier
  def new_direct_message
    ...

    push apn: "device-token", fcm: true
  end
end
```

#### Edit the Notifier

```ruby
# app/notifiers/tweet_notifier.rb
class TweetNotifier < ApplicationNotifier
  def new_direct_message(tweet_id, token_id)
    @tweet = Tweet.find(id)
    @token = DeviceToken.find(token_id)

    push apn: @token.apn? && @token.device_token, fcm: @token.fcm?
  end
end
```

#### Edit the Push Notification Payload


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

```ruby
TweetNotifier.new_direct_message(tweet_id, token_id).deliver_now!
# => sends a push notification immediately

TweetNotifier.new_direct_message(tweet_id, token_id).deliver_later!
# => enqueues a job that sends a push notification later
```

## Error Handling

### APN:

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

### FCM:

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

## Observers

```ruby
# app/observers/fcm_token_handler.rb
class FcmTokenHandler
  def delivered_notification(payload, response)
    return if response.json[:canonical_ids].zero?

    response.json[:results].select {|result| result[:registration_id] }.each_with_index do |result, index|      
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

TODO

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yuki24/pushing. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
