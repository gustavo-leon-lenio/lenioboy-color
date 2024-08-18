extends HBoxContainer

onready var heart_sprite: Sprite = $HeartGUI/Sprite


func _ready() -> void:
	# warning-ignore:return_value_discarded
	Conductor.connect("beat", self, "on_beat")
# warning-ignore:return_value_discarded
	Global.connect("health_changed", self, "on_health_changed")


func set_tween_scale():
	var tween: SceneTreeTween = create_tween()
# warning-ignore:return_value_discarded
	tween.set_trans(Tween.TRANS_BOUNCE)
# warning-ignore:return_value_discarded
	tween.tween_property(heart_sprite, "scale", Vector2(2, 2), 0.1)
# warning-ignore:return_value_discarded
	tween.tween_property(heart_sprite, "scale", Vector2(1.5, 1.5), 0.1)


func on_beat(_beat: int) -> void:
	set_tween_scale()


func on_health_changed(new_health: int):
	heart_sprite.frame = new_health
