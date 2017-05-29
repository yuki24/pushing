# Pushing

**This gem is currently in beta.**

Pushing is a push notification framework that implements similar interfaces that ActionMailer provides.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pushing'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pushing

## Usage
```ruby
# config/initializers/pushing.rb
Pushing::Platforms.configure do |config|
  config.fcm.adapter    = Rails.env.test? ? :test : :andpush
  config.fcm.server_key = 'YOUR_FCM_TEST_SERVER_KEY'

  config.apn.environment          = Rails.env.production? ? 'production' : 'development'
  config.apn.adapter              = Rails.env.test? ? :test : :andpush
  config.apn.topic                = 'net.yukinishijima.yourapp'
  config.apn.certificate_path     = '/path/to/your_certificate.pem'
  config.apn.certificate_password = 'PASSWORD_FOR_CERT'
end
```

```ruby
# app/notifiers/weather_notifier.rb
class WeatherNotifier < Pushing::Base
  def weather_update(weather_update_id, device_id)
    @weather = WeatherUpdate.find(weather_update_id)
    @device  = Device.find(device_id)

    # The :fcm key should be true or false while the :apn key should be a valid device token or a falsy value
    push fcm: @device.android?, apn: @device.ios? && @device.apns_device_token
  end
end
```

```ruby
# app/views/weather_notifier/weather_update.json+apn.jbuilder
json.aps do
  json.alert do
    json.title @weather.title
    json.body  @weather.summary
  end

  json.badge 5
  json.sound "bingbong.aiff"
end

json.full_content @weather.content
json.created_at   @weather.created_at
```

```ruby
# app/views/weather_notifier/weather_update.json+fcm.jbuilder
json.to @device.registration_token

json.notification do
  json.title @weather.title
  json.body  @weather.summary
end

json.data do
  json.full_content @weather.content
  json.created_at   @weather.created_at
end
```

```ruby
WeatherNotifier.weather_update(weather_update_id, device_id).deliver_now!
# => sends a push notification immediately

WeatherNotifier.weather_update(weather_update_id, device_id).deliver_later!
# => enqueues a job that sends a push notification later
```

## Running Integration Tests

```sh
FCM_TEST_SERVER_KEY='...' FCM_TEST_REGISTRATION_TOKEN='...' appraisal rails_50 ruby -I"lib:test" test/integration_test.rb
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yuki24/pushing. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
