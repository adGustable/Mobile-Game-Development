extends Node

@onready var plugin = Engine.get_singleton("GodotNotification") if Engine.has_singleton("GodotNotification") else null

func _ready():
	print("NotificationManager ready! OS: ", OS.get_name())
	if plugin:
		print("Plugin found!")
		setup_notifications()
	else:
		print("Plugin NOT found - using fallback")

func setup_notifications():
	if plugin.has_post_notifications_permission():
		create_notification_channel()
	else:
		plugin.request_post_notifications_permission()
		await get_tree().create_timer(1.0).timeout
		if plugin.has_post_notifications_permission():
			create_notification_channel()

func create_notification_channel():
	var channel = {
		"id": "game_notifications",
		"name": "Game Notifications",
		"description": "Notifications for game achievements",
		"importance": 3  # DEFAULT importance
	}
	plugin.create_notification_channel(channel)
	print("Notification channel created!")

func send_notification(title: String, message: String, delay: int = 0):
	if plugin:
		var notification = {
			"id": randi() % 10000,
			"channel_id": "game_notifications",
			"title": title,
			"content": message,
			"small_icon": "ic_notification",
			"delay": delay
		}
		plugin.schedule(notification)
	else:
		OS.alert(title, message)

func send_android_notification():
	if not plugin:
		print("Plugin not available")
		OS.alert("🎉 Level Complete! 🎉", "Congratulations!")
		return
	
	# Check permission again before sending
	if not plugin.has_post_notifications_permission():
		print("No notification permission - requesting again...")
		plugin.request_post_notifications_permission()
		OS.alert("🎉 Level Complete! 🎉\n(Please allow notifications in settings)", "Congratulations!")
		return
	
	# Create notification data with better content
	var notification_data = NotificationData.new()
	notification_data.set_id(1)
	notification_data.set_channel_id("game_notifications")
	notification_data.set_title("🎉 Level Complete!")
	notification_data.set_content("Great job! You've completed another level!")
	#notification_data.set_small_icon_name("icon")  # This might need to be "ic_notification"
	notification_data.set_small_icon_name("ic_notification")  # Standard Android notification icon
	
	notification_data.set_delay(0)  # Show immediately
	
	# Schedule the notification
	plugin.schedule(notification_data.get_raw_data())
	print("Android notification scheduled with permission check!")
	print("If notification doesn't appear, the issue is likely the icon")
	
	# Also show alert as backup for now
	OS.alert("🎉 Level Complete! 🎉\n(Check notification bar)", "Congratulations!")
