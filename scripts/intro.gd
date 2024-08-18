extends Control

onready var audio_logo = $AudioStreamPlayer
onready var animation_player = $AnimationPlayer


func _ready():
	animation_player.play("boot")


func goto_next_scene() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/ui/menu.tscn")
