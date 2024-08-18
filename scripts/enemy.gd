class_name Enemy
extends Area2D


@export var visibility_notifier: VisibleOnScreenNotifier2D

func _ready() -> void:
	if visibility_notifier:
		visibility_notifier.connect("screen_exited", queue_free)
	connect("area_entered", on_area2d_entered)

func on_area2d_entered(area: Area2D) -> void:
	if area.has_method("damage"):
		var attack: Attack = Attack.new(1)
		area.damage(attack)
