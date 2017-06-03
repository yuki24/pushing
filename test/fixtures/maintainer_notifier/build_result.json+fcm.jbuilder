json.to ENV.fetch("FCM_TEST_REGISTRATION_TOKEN")
json.dry_run true

json.notification do
  json.title "Build was successfully run"
  json.body  "The tests for #{@ruby_version}, Rails #{@rails_version} andadapter #{@adapter} has passed."
end

# json.data do
  # json.full_message 'The New York City region was predicted to receive as much as 20 inches of snow.'
# end
