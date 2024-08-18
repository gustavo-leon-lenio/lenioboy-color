extends Control

const power_on_sound: AudioStream = preload("res://assets/sounds/fxs/power_switch.wav")

var my_scenes: Array[String] = [
	"res://scenes/intros/intro_gb.tscn",
	"res://scenes/intros/intro_gbc.tscn",
	"res://scenes/intros/intro_gba.tscn",
]

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var power_switch: TextureButton = $HBoxContainer/Button


#func _ready() -> void:
	#AudioServer.register_stream_as_sample(power_on_sound)

func turn_on_lenioboy() -> void:
	randomize()
	audio_player.play()


func on_button_pressed(button_pressed: bool) -> void:
	if not button_pressed:
		power_switch.set_pressed_no_signal(true)
		return
	if button_pressed:
		turn_on_lenioboy()


func _on_audio_stream_player_finished() -> void:
	var scene_index: int = randi() % my_scenes.size()
	get_tree().change_scene_to_file(my_scenes[scene_index])
