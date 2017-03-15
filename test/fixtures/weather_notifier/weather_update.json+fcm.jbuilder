json.to ENV.fetch("FCM_TEST_REGISTRATION_TOKEN")

json.notification do
  json.title "How Much Snow Has Fallen"
  json.body  "The New York City region was predicted to receive as much as 20 inches of snow."
end

json.data do
  json.full_message 'The New York City region was predicted to receive as much as 20 inches of snow.'
end
