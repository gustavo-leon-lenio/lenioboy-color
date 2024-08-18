extends Node

@export var group_nodes: Node2D


func _ready() -> void:
	Conductor.connect("beat", on_beat)


func set_tween_scale() -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(group_nodes, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(group_nodes, "scale", Vector2(1, 1), 0.1)


func on_beat(_beat: int) -> void:
	set_tween_scale()
