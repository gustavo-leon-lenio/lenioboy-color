extends Control

onready var message_arrays = [
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
onready var message_label: Label = $CanvasLayer/Control/VBoxContainer/Message
onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
	get_tree().paused = false
	message_label.text = message_arrays[randi() % message_arrays.size()]
	yield(
		SilentWolf.Scores.persist_score(Global.player_data.name, Global.get_score()),
		"sw_score_posted"
	)


func change_to_game():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/game.tscn")  # Change to the next scene


func change_to_menu():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/ui/menu.tscn")  # Change to the next scene


func on_tryagain_pressed():
	animation_player.play("blink_fast_to_game")


func on_goback_pressed():
	animation_player.play("blink_fast_to_menu")
