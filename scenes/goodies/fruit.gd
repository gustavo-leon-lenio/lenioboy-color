class_name Fruit extends Area2D

@export var anim_sprite: AnimatedSprite2D


func _ready() -> void:
	set_anim()
	set_tween_scale()


func set_anim() -> void:
	var animations: PackedStringArray = anim_sprite.sprite_frames.get_animation_names()
	var animation_count: int = animations.size()
	var random_index: int = randi() % animation_count
	anim_sprite.play(animations[random_index])


func set_tween_scale() -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_loops()
	tween.tween_property(anim_sprite, "scale", Vector2(1.2, 1.3), 0.2)
	tween.tween_property(anim_sprite, "scale", Vector2(1, 1), 0.2)


func on_area2_d_area_entered(area: Area2D) -> void:
	if area.has_method("heal"):
		var heal: Heal = Heal.new(1)
		area.heal(heal)
