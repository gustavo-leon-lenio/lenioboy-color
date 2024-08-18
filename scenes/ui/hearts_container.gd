extends HBoxContainer

@onready var heart_sprite: Sprite2D = $HeartGUI/Sprite2D


func _ready() -> void:
	Conductor.connect("beat", on_beat)
	Global.connect("health_changed", on_health_changed)


func set_tween_scale() -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(heart_sprite, "scale", Vector2(2, 2), 0.1)
	tween.tween_property(heart_sprite, "scale", Vector2(1.5, 1.5), 0.1)


func on_beat(_beat: int) -> void:
	set_tween_scale()


func on_health_changed(new_health: int) -> void:
	heart_sprite.frame = new_health
