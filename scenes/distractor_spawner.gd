extends Node2D

@onready var thumb_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var tween: Tween


func _ready() -> void:
    Conductor.connect("distractor_beat_signal", on_beat)


func start_tween() -> void:
    tween = create_tween()
    tween.set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(thumb_sprite, "global_position:x", 175, 1.2).as_relative()
    tween.tween_interval(1)
    tween.tween_property(thumb_sprite, "global_position:x", -175, 1.2).as_relative()


func _on_Timer_timeout() -> void:
    start_tween()


func on_beat() -> void:
    if Global.level >= 3:
        timer.start()
