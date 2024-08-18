extends Control

@onready var message_arrays: Array[String] = [
	"You ran so fast that your shoes asked for a break!",
	"Oops! Leni got tired of running and started moonwalking.",
	"Looks like Leni mistook the track for a dance floor.",
	"You outran the competition, but the ground decided to quit.",
	"Leni tried to high-five a snail, and it won.",
	"Better luck next time! Leni tripped over a pixel.",
	"Leni ran out of breath and found it hilarious.",
	"Leni ran so far that they ended up in the wrong game.",
	"You broke the sound barrier, but the game physics stayed intact.",
	"Leni challenged a tortoise to a rematch."
]
@onready var message_label: Label = $CanvasLayer/Control/VBoxContainer/Message
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	get_tree().paused = false
	message_label.text = message_arrays[randi() % message_arrays.size()]
	var current_score: float = float("%0.2f" % Global.get_score())
	await SilentWolf.Scores.save_score(Global.player_data.name,current_score)

func change_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")

func on_tryagain_pressed() -> void:
	animation_player.play("blink_fast_to_game")

func on_goback_pressed() -> void:
	animation_player.play("blink_fast_to_menu")

func change_to_game()-> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
