<% module_namespacing do -%>
class <%= class_name %>Notifier < ApplicationNotifier
<% actions.each do |action| -%>
  def <%= action %>
    @greeting = "Hi"

    push apn: "device-token", fcm: true
  end
<% end -%>
end
<% end -%>
