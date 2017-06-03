json.aps do
  json.alert do
    json.title "Build was successfully run"
    json.body  "The tests for #{@ruby_version}, Rails #{@rails_version}, adapter #{@adapter} has passed."
  end

  json.badge 1
  json.sound "bingbong.aiff"
end

# json.full_message 'The New York City region was predicted to receive as much as 20 inches of snow.'

