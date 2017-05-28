# In this file you can customize the APN payload. For more details about key
# preference, see Apple's offitial documentation here: http://bit.ly/apns-doc

# the JSON dictionary can include custom keys and values with your app-specific
# content.
# json.custom_data1 'content1...'
# json.custom_data2 'content2...'

# The aps dictionary contains the keys used by Apple to deliver the
# notification to the user's device.
json.aps do

  # Include this key when you want the system to display a standard alert or a
  # banner (Dictionary or String).
  # json.alert 'REPLACE_WITH_ACTUAL_TITLE'
  json.alert do
    # A short string describing the purpose of the notification.
    json.title 'REPLACE_WITH_ACTUAL_TITLE'

    # The text of the alert message.
    json.body 'REPLACE_WITH_ACTUAL_BODY'

    # The key to a title string in the Localizable.strings file for the current
    # localization.
    # json.set! 'title-loc-key', 'key in Localizable.strings'

    # Variable string values to appear in place of the format specifiers in
    # title-loc-key.
    # json.set! 'title-loc-args', ['arg1', 'arg2']

    # If a string is specified, the system displays an alert that includes the
    # Close and View buttons.
    # json.set! 'action-loc-key', 'key in Localizable.strings'

    # A key to an alert-message string in a Localizable.strings file for the
    # current localization.
    # json.set! 'loc-key', 'key in Localizable.strings'

    # Variable string values to appear in place of the format specifiers in
    # loc-key.
    # json.set! 'loc-args', ['arg1', 'arg2']

    # The filename of an image file in the app bundle, with or without the
    # filename extension.
    # json.set! 'launch-image', 'your_launch_iamge.png'
  end

  # Include this key when you want the system to modify the badge of your app
  # icon.
  json.badge 1

  # Include this key when you want the system to play a sound.
  json.sound 'bingbong.aiff'

  # Provide this key with a string value that represents the notification's
  # type.
  # json.category 'your-category-type', 'CATEGORY-TYPE'

  # Include this key with a value of 1 to configure a silent notification.
  # json.set! 'content-available', 1

  # Provide this key with a string value that represents the app-specific
  # identifier for grouping notifications.
  # json.set! 'thread-id', 'THREAD-ID'
end
