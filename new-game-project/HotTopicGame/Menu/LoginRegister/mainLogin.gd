extends Node

@onready var scene_tree = get_tree()
@onready var notification_scheduler: NotificationScheduler = $NotificationScheduler
@onready var check_init_timer: Timer = $CheckInitTimer

var scheduler_ready := false

func _ready() -> void:
	Auth.load_user_data()
	var scheduler = get_node("NotificationScheduler")
	scheduler.initialization_completed.connect(_on_scheduler_ready)
	scheduler.initialize()

	# Connect signals
	notification_scheduler.notification_opened.connect(_on_notification_opened)
	notification_scheduler.permission_granted.connect(_on_permission_granted)
	notification_scheduler.permission_denied.connect(_on_permission_denied)

	# Start polling to wait for plugin readiness
	check_init_timer.start()

func _on_scheduler_ready():
	print("NotificationScheduler initialized and ready")
	# Now you can safely create notification channels, schedule notifications, etc.
	# For example:
	# scheduler.create_notification_channel(my_channel)
	# scheduler.schedule(my_notification)
	# Send immediate test notification (native system)
	if Engine.has_singleton("GodotNotification"):
		var notification = Engine.get_singleton("GodotNotification")
		notification.notify(1, "Test Notification", "This is a test message.")

func _on_CheckInitTimer_timeout():
	if notification_scheduler.has_post_notifications_permission():
		check_init_timer.stop()
		scheduler_ready = true
		print("NotificationScheduler plugin is ready.")

		# Request permission if not granted
		if not notification_scheduler.has_post_notifications_permission():
			notification_scheduler.request_post_notifications_permission()
		else:
			_on_permission_granted()

		schedule_test_notification()
	else:
		print("Waiting for NotificationScheduler to initialize...")

func _on_permission_granted():
	var channel := NotificationChannel.new()
	channel.set_id("main_channel")
	channel.set_name("Main Notifications")
	channel.set_description("General notifications")
	channel.set_importance(NotificationChannel.Importance.DEFAULT)

	notification_scheduler.create_notification_channel(channel)
	print("Notification channel created!")

func _on_notification_opened(notification_id: int):
	print("Notification with ID %d was opened." % notification_id)

func _on_permission_denied(permission_name: String) -> void:
	print("Permission denied for: ", permission_name)

func schedule_test_notification():
	var notification := NotificationData.new()
	notification.set_id(1)\
		.set_channel_id("main_channel")\
		.set_title("Hello!")\
		.set_content("This is a test notification.")\
		.set_small_icon_name("ic_notify")\
		.set_delay(10)  # seconds

	notification_scheduler.schedule(notification)
	print("Test notification scheduled.")


func _on_register_btn_pressed() -> void:
	# Path to your Register Page scene
	var register_scene = load("res://HotTopicGame/Menu/LoginRegister/Register/RegisterPage.tscn") 
	if register_scene:
	# Change to the Register Page scene
		get_tree().change_scene_to_packed(register_scene)
	else:
		print("ERROR!")


func _on_login_btn_pressed() -> void:
	# Path to your Login Page scene
	var login_scene = load("res://HotTopicGame/Menu/LoginRegister/Login/Login.tscn") 
	if login_scene:
	# Change to the Login Page scene
		get_tree().change_scene_to_packed(login_scene)
	else:
		print("ERROR!")


func initialization_completed() -> void:
	pass # Replace with function body.
