extends Node

# warning-ignore:unused_signal
signal change_speed(new_speed)
signal level_changed(new_level)
signal coins_changed(new_coins)
# warning-ignore:unused_signal
signal game_over_changed(new_bool)
# warning-ignore:unused_signal
signal health_changed(new_health)

const SAVE_FILE: String = "user://save_file.save"
const MAX_HEALTH: int = 2

# Current level in the game.
var player_data: Dictionary = {}
var level: int = 1 setget set_level, get_level
var game_speed: float = 150.0 setget set_speed, get_speed
var game_score: float = 0 setget set_score, get_score
var game_coins: int = 0 setget set_coins, get_coins
var is_game_over: bool = false setget set_game_over, get_game_over
var scroll_dir: int = -1 setget , get_scroll_dir
var highest_score: Dictionary = {"score": 0}

onready var level_list: Dictionary = {
	1: {"bpm": 100, "max_notes": 1, "enemy_types": 1},
	2: {"bpm": 118, "max_notes": 1, "enemy_types": 2},
	3: {"bpm": 118, "max_notes": 2, "enemy_types": 1},
	4: {"bpm": 118, "max_notes": 2, "enemy_types": 2},
	5: {"bpm": 138, "max_notes": 2, "enemy_types": 1},
	6: {"bpm": 138, "max_notes": 3, "enemy_types": 2},
	7: {"bpm": 138, "max_notes": 4, "enemy_types": 2},
}
onready var player_health: int = MAX_HEALTH setget set_health, get_health


func _ready():
	randomize()
	load_player_data()


func set_speed(new_speed) -> void:
	game_speed = new_speed


func get_speed() -> float:
	return game_speed


func set_level(new_level: int) -> void:
	level = new_level
	emit_signal("level_changed", level)


func get_level() -> int:
	return level


func set_score(new_score: float) -> void:
	game_score = new_score


func get_score() -> float:
	return game_score


func set_health(new_health) -> void:
	player_health = new_health
	emit_signal("health_changed", player_health)
	if player_health <= 0:
		Global.is_game_over = true


func get_health() -> int:
	return player_health


func set_coins(new_coins) -> void:
	game_coins = new_coins
	if game_coins != 0:
		emit_signal("coins_changed", game_coins)


func get_coins() -> int:
	return game_coins


func set_game_over(new_bool: bool) -> void:
	is_game_over = new_bool
	emit_signal("game_over_changed", is_game_over)


func get_game_over() -> bool:
	return is_game_over


func get_scroll_dir() -> int:
	return scroll_dir


func change_scene(scene_path: String) -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene(scene_path)


func set_highest_score() -> void:
	yield(SilentWolf.Scores.get_high_scores(0), "sw_scores_received")
	highest_score = SilentWolf.Scores.scores[0]


func load_player_data() -> void:
	var file: File = File.new()
	if not file.file_exists(SAVE_FILE):
		player_data = {"name": ""}
		save_player_data()

	var error = file.open(SAVE_FILE, file.READ)
	if error != OK:
		return
	player_data = file.get_var()
	file.close()


func save_player_data() -> void:
	var file: File = File.new()
	var error = file.open(SAVE_FILE, file.WRITE)
	if error != OK:
		return
	file.store_var(player_data)
	file.close()
