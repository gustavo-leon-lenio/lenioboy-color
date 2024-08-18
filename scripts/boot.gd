extends Control

var my_scenes = [
	"res://scenes/intros/intro_gb.tscn",
	"res://scenes/intros/intro_gbc.tscn",
	"res://scenes/intros/intro_gba.tscn",
]

onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
onready var power_switch: TextureButton = $HBoxContainer/Button


func turn_on_lenioboy():
	randomize()
	audio_player.play()
	yield(audio_player, "finished")
	var scene_index = randi() % my_scenes.size()
	# warning-ignore:return_value_discarded
	get_tree().change_scene(my_scenes[scene_index])


func on_button_pressed(button_pressed: bool) -> void:
	if not button_pressed:
		power_switch.set_pressed_no_signal(true)
		return
	if button_pressed:
		turn_on_lenioboy()
