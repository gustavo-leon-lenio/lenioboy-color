extends Control

# const COIN_UP_SOUND: AudioStream = preload("res://assets/sounds/fxs/chiptune_coin.wav")
# const GBA_BOOT_SOUND: AudioStream = preload("res://assets/sounds/fxs/gba_boot.ogg")

@onready var audio_logo: AudioStreamPlayer = $AudioStreamPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	# AudioServer.register_stream_as_sample(COIN_UP_SOUND)
	# AudioServer.register_stream_as_sample(GBA_BOOT_SOUND)
	animation_player.play("boot")


func goto_next_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")
