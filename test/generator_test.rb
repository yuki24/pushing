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
      assert_match(/Pushing::Platforms.configure do |config|/, notifier)
    end

    assert_file "app/notifiers/application_notifier.rb" do |notifier|
      assert_match(/class ApplicationNotifier < Pushing::Base/, notifier)
    end

    assert_file "app/notifiers/tweet_notifier.rb" do |notifier|
      assert_match(/class TweetNotifier < ApplicationNotifier/, notifier)
    end
  end
end
