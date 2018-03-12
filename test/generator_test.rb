require "test_helper"
require "rails/generators/test_case"

require 'generators/pushing/notifier_generator'

class NotifierGeneratorTest < Rails::Generators::TestCase
  tests Pushing::NotifierGenerator
  arguments %w(TweetNotifier new_mention_in_tweet)
  destination File.join(File.expand_path('../', File.dirname(__FILE__)), "tmp")
  setup :prepare_destination

  test "notifier skeleton is created" do
    run_generator

    assert_file "config/initializers/pushing.rb" do |notifier|
      assert_match(/Pushing.configure do |config|/, notifier)
    end

    assert_file "app/notifiers/application_notifier.rb" do |notifier|
      assert_match(/class ApplicationNotifier < Pushing::Base/, notifier)
    end

    assert_file "app/notifiers/tweet_notifier.rb" do |notifier|
      assert_match(/class TweetNotifier < ApplicationNotifier/, notifier)
    end

    assert_file "app/views/tweet_notifier/new_mention_in_tweet.json+apn.jbuilder" do |view|
      assert_match(/json\.aps do/, view)
    end

    assert_file "app/views/tweet_notifier/new_mention_in_tweet.json+fcm.jbuilder" do |view|
      assert_match(/json\.to 'REPLACE_WITH_ACTUAL_REGISTRATION_ID_OR_TOPIC'/, view)
    end
  end
end
