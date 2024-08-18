extends Node2D

onready var thumb_sprite: AnimatedSprite = $AnimatedSprite
onready var timer: Timer = $Timer
onready var tween: SceneTreeTween


func _ready() -> void:
	# warning-ignore:return_value_discarded
	Conductor.connect("distractor_beat", self, "on_beat")


func start_tween() -> void:
	tween = create_tween()
	# warning-ignore:return_value_discarded
	tween.set_trans(Tween.TRANS_CUBIC)
	# warning-ignore:return_value_discarded
	tween.tween_property(thumb_sprite, "global_position:x", 170, 1.2).as_relative()
	# warning-ignore:return_value_discarded
	tween.tween_interval(1)
	# warning-ignore:return_value_discarded
	tween.tween_property(thumb_sprite, "global_position:x", -170, 1.2).as_relative()


func _on_Timer_timeout() -> void:
	start_tween()  # Replace with function body.


func on_beat() -> void:
	if Global.level >= 6:
		timer.start()
