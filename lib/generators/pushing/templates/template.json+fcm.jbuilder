# In this file you can customize the FCM payload. For more details about Firebase Cloud Messaging HTTP Protocol, see
# Google's offitial documentation here: https://goo.gl/tgssxy

# The recipient of a message. The value can be a device's registration token, a device group's notification key, or a
# single topic (prefixed with /topics/). Either the 'to' or 'registration_ids' key should be present.
json.to 'REPLACE_WITH_ACTUAL_REGISTRATION_ID_OR_TOPIC'

# The recipient of a multicast message, a message sent to more than one registration token. Either the 'to' or
# 'registration_ids' key should be present.
# json.registration_ids 'REPLACE_WITH_ACTUAL_REGISTRATION_IDS_OR_TOPIC'

# A logical expression of conditions that determine the message target.
# json.condition 'Topic'

# This parameter identifies a group of messages (e.g., with collapse_key:
# "Updates Available") that can be collapsed.
# json.collapse_key "Updates Available"

# Sets the priority of the message. Valid values are "normal" and "high".
# json.priority "high"

# How long (in seconds) the message should be kept in FCM storage if the device is offline.
# json.time_to_live 4.weeks.to_i

# The package name of the application where the registration tokens must match in order to receive the message.
# json.restricted_package_name 'com.yourdomain.app'

# This parameter, when set to true, allows developers to test a request without actually sending a message.
# json.dry_run true

# The custom key-value pairs of the message's payload.
# json.data do
#   json.custom_data "data..."
# end

# The predefined, user-visible key-value pairs of the notification payload. 
json.notification do
  # The notification's title.
  json.title 'REPLACE_WITH_ACTUAL_TITLE'

  # The notification's body text.
  json.body 'REPLACE_WITH_ACTUAL_BODY'

  # The notification's channel id (new in Android O).
  # json.android_channel_id "my_channel_01"

  # The notification's icon.
  json.icon 1

  # The sound to play when the device receives the notificatio
  json.sound 'default'

  # Identifier used to replace existing notifications in the notification drawer.
  # json.tag 'tag-name'

  # The notification's icon color, expressed in #rrggbb format.
  # json.color "#ffffff"

  # The action associated with a user click on the notification.
  # json.click_action "OPEN_ACTIVITY_1"

  # The key to the body in the app's string resources to use to localize the body to the user's current localization.
  # json.body_loc_key 'key in Localizable.strings'

  # String values to be used in place of the format specifiers in 'body_loc_key' to use to localize the body to the
  # user's current localization.
  # json.body_loc_args ['arg1', 'arg2']

  # The key to the title in the app's string resources to use to localize the title to the user's current localization.
  # json.title_loc_key 'key in Localizable.strings'

  # String values to be used in place of the format specifiers in title_loc_key to use to localize the title text to
  # the user's current localization.
  # json.title_loc_args ['arg1', 'arg2']
end
