extends Area2D

onready var anim_sprite: AnimatedSprite = $AnimatedSprite


func _ready() -> void:
	set_anim()
	set_tween_scale()


func set_anim():
	var animations = anim_sprite.frames.get_animation_names()
	var animation_count = animations.size()
	var random_index = randi() % animation_count
	anim_sprite.play(animations[random_index])
# warning-ignore:return_value_discarded
	connect("area_entered", self, "on_area2_d_area_entered")


func set_tween_scale():
	var tween: SceneTreeTween = create_tween()
# warning-ignore:return_value_discarded
	tween.set_trans(Tween.TRANS_BOUNCE)
# warning-ignore:return_value_discarded
	tween.set_loops()
# warning-ignore:return_value_discarded
	tween.tween_property(anim_sprite, "scale", Vector2(1.2, 1.3), 0.2)
# warning-ignore:return_value_discarded
	tween.tween_property(anim_sprite, "scale", Vector2(1, 1), 0.2)


func on_area2_d_area_entered(area: Area2D) -> void:
	if area.has_method("heal"):
		var heal: Heal = Heal.new(1)
		area.heal(heal)
