json.aps do
  json.alert "I'm sending you URLs!"
end

json.url_from_action @url_for
json.url_in_view     url_for(@options)

json.welcome_url_from_action @welcome_url
json.welcome_url_in_view     welcome_url

json.asset_url asset_url('puppy.jpeg')
json.image_url image_url('puppy.jpeg')
