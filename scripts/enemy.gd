class_name Enemy
extends Area2D


func _ready() -> void:
	var visibility_notifier = VisibilityNotifier2D.new()
	add_child(visibility_notifier)
	visibility_notifier.connect(
		"screen_exited", self, "on_visible_on_screen_notifier_2d_screen_exited"
	)
	# warning-ignore:return_value_discarded
	connect("area_entered", self, "on_area2d_entered")


func on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func on_area2d_entered(area: Area2D) -> void:
	if area.has_method("damage"):
		var attack: Attack = Attack.new(1)
		area.damage(attack)
