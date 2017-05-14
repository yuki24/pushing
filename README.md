# Fourseam

**This gem is currently in beta.**

Fourseam is a push notification framework that implements similar interfaces that ActionMailer provides.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fourseam'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fourseam

## Usage
```ruby
# config/initializers/fourseam.rb
Fourseam::Base.configure do |config|
  config.fcm.adapter    = Rails.env.test? ? :test : :robo_msg
  config.fcm.server_key = 'YOUR_FCM_TEST_SERVER_KEY'

  config.apn.environment          = Rails.env.production? ? 'production' : 'development'
  config.apn.adapter              = Rails.env.test? ? :test : :robo_msg
  config.apn.topic                = 'net.yukinishijima.yourapp'
  config.apn.certificate_path     = '/path/to/your_certificate.pem'
  config.apn.certificate_password = 'PASSWORD_FOR_CERT'
end
```

```ruby
# app/notifiers/weather_notifier.rb
class WeatherNotifier < Fourseam::Base
  def weather_update(weather_update_id, user_id)
    @weather_update = WeatherUpdate.find(weather_update_id)
    @user           = User.find(uesr_id)

    push apn: @user.ios_device.apn_token, fcm: true
  end
end
```

```ruby
# app/views/weather_notifier/weather_update.json+apn.jbuilder
json.aps do
  json.alert do
    json.title @weather_update.title
    json.body  @weather_update.summary
  end

  json.badge 5
  json.sound "bingbong.aiff"
end

json.full_content @weather_update.content
json.created_at   @weather_update.created_at
```

```ruby
# app/views/weather_notifier/weather_update.json+fcm.jbuilder
json.to @user.android_device.registration_token

json.notification do
  json.title @weather_update.title
  json.body  @weather_update.summary
end

json.data do
  json.full_content @weather_update.content
  json.created_at   @weather_update.created_at
end
```

```ruby
WeatherNotifier.weather_update(weather_update_id, user_id).deliver_now!
# => sends push notifications immediately

WeatherNotifier.weather_update(weather_update_id, user_id).deliver_later!
# => enqueues a job that sends push notifications later
```

## Running Integration Tests

```sh
FCM_TEST_SERVER_KEY='...' FCM_TEST_REGISTRATION_TOKEN='...' appraisal rails_50 ruby -I"lib:test" test/integration_test.rb
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yuki24/fourseam. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
