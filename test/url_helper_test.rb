# frozen_string_literal: true

require 'test_helper'
require "action_controller"

class WelcomeController < ActionController::Base
end

AppRoutes = ActionDispatch::Routing::RouteSet.new

Pushing::Base.include AppRoutes.url_helpers

class UrlTestNotifier < Pushing::Base
  self.default_url_options[:host] = "www.basecamphq.com"
  self.asset_host = "https://www.basecamphq.com"

  configure do |c|
    c.assets_dir = "" # To get the tests to pass
  end

  def url(options)
    @options     = options
    @url_for     = url_for(options)
    @welcome_url = url_for host: "example.com", controller: "welcome", action: "greeting"

    push apn: 'token'
  end
end

class UrlHelperTest < ActiveSupport::TestCase
  class DummyModel
    def self.model_name
      OpenStruct.new(route_key: "dummy_model")
    end

    def persisted?
      false
    end

    def model_name
      self.class.model_name
    end

    def to_model
      self
    end
  end

  def assert_url_for(expected, options, relative = false)
    expected = "http://www.basecamphq.com#{expected}" if expected.start_with?("/") && !relative
    urls     = UrlTestNotifier.url(options).apn.payload.reject{ |key, _| key == :aps }.values

    assert_equal expected, urls.first
    assert_equal expected, urls.second
  end

  test '#url_for' do
    AppRoutes.draw do
      ActiveSupport::Deprecation.silence do
        get ":controller(/:action(/:id))"
        get "/welcome" => "foo#bar", as: "welcome"
        get "/dummy_model" => "foo#baz", as: "dummy_model"
      end
    end

    # string
    assert_url_for "http://foo/", "http://foo/"

    # symbol
    assert_url_for "/welcome", :welcome

    # hash
    assert_url_for "/a/b/c", controller: "a", action: "b", id: "c"
    assert_url_for "/a/b/c", { controller: "a", action: "b", id: "c", only_path: true }, true

    # model
    assert_url_for "/dummy_model", DummyModel.new

    # class
    assert_url_for "/dummy_model", DummyModel

    # array
    assert_url_for "/dummy_model", [DummyModel]
  end

  test 'url helpers' do
    AppRoutes.draw do
      ActiveSupport::Deprecation.silence do
        get ":controller(/:action(/:id))"
        get "/welcome" => "foo#bar", as: "welcome"
      end
    end

    payload = UrlTestNotifier.url(:welcome).apn.payload

    assert_equal 'http://example.com/welcome/greeting', payload[:welcome_url_from_action]
    assert_equal 'http://www.basecamphq.com/welcome',   payload[:welcome_url_in_view]
  end

  test 'asset url helpers' do
    AppRoutes.draw do
      ActiveSupport::Deprecation.silence do
        get ":controller(/:action(/:id))"
        get "/welcome" => "foo#bar", as: "welcome"
      end
    end

    payload = UrlTestNotifier.url(:welcome).apn.payload

    assert_equal 'https://www.basecamphq.com/puppy.jpeg',        payload[:asset_url]
    assert_equal 'https://www.basecamphq.com/images/puppy.jpeg', payload[:image_url]
  end
end
