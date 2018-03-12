require 'test_helper'

class PlatformsTest < ActiveSupport::TestCase
  setup do
    @id          = 1
    @expiration  = 1.hour.from_now
    @priority    = 5
    @topic       = 'com.yuki.ios'
    @collapse_id = 'pushing-testing'
  end

  test "APN headers are normalized" do
    payload = Pushing::Platforms::ApnPayload.new({}, environment: 'development', headers: {
      authorization:      "",
      'apns-id':          @id,
      'apns-expiration':  @expiration,
      'apns-priority':    @priority,
      'apns-topic':       @topic,
      'apns-collapse-id': @collapse_id
    })

    assert_apn_headers payload.headers
  end

  test "APN headers with underscore are normalized" do
    payload = Pushing::Platforms::ApnPayload.new({}, environment: 'development', headers: {
      authorization:    "",
      apns_id:          @id,
      apns_expiration:  @expiration,
      apns_priority:    @priority,
      apns_topic:       @topic,
      apns_collapse_id: @collapse_id
    })

    assert_apn_headers payload.headers
  end

  test "APN headers without 'apn-' prefix are normalized" do
    payload = Pushing::Platforms::ApnPayload.new({}, environment: 'development', headers: {
      authorization: "",
      id:            @id,
      expiration:    @expiration,
      priority:      @priority,
      topic:         @topic,
      collapse_id:   @collapse_id
    })

    assert_apn_headers payload.headers
  end

  test "default headers do not take the precedence" do
    options = {
      environment: 'development',
      headers: {
        priority: 10
      }
    }

    config = {
      default_headers: {
        apns_priority: 5
      }
    }

    payload = Pushing::Platforms::ApnPayload.new({}, options, config)

    assert_equal 10, payload.headers[:'apns-priority']
    assert_not payload.headers.include?(:apns_priority)
    assert_not payload.headers.include?(:priority)
  end

  private

  def assert_apn_headers(headers)
    assert_equal '',           headers[:authorization]
    assert_equal @id,          headers[:'apns-id']
    assert_equal @expiration,  headers[:'apns-expiration']
    assert_equal @priority,    headers[:'apns-priority']
    assert_equal @topic,       headers[:'apns-topic']
    assert_equal @collapse_id, headers[:'apns-collapse-id']
  end
end
