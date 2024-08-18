extends Node

# warning-ignore:unused_signal
@warning_ignore("unused_signal")
signal change_speed(new_speed: float)
@warning_ignore("unused_signal")
signal level_changed(new_level: int)
@warning_ignore("unused_signal")
signal coins_changed(new_coins: int)
# warning-ignore:unused_signal
@warning_ignore("unused_signal")
signal game_over_changed(new_bool: bool)
# warning-ignore:unused_signal
@warning_ignore("unused_signal")
signal health_changed(new_health: int)

const SAVE_FILE: String = "user://save_file.dat"
const MAX_HEALTH: int = 2

# Current level in the game.
var player_data: Dictionary = {}
var level: int = 1:
	get = get_level,
	set = set_level
var game_speed: float = 150.0:
	get = get_velocity,
	set = set_velocity
var game_score: float = 0:
	get = get_score,
	set = set_score
var game_coins: int = 0:
	get = get_coins,
	set = set_coins
var is_game_over: bool = false:
	get = get_game_over,
	set = set_game_over
var scroll_dir: int = -1:
	get = get_scroll_dir
var highest_score: Dictionary = {"score": 0}

@onready var level_list: Dictionary = {
	1: {"bpm": 100, "max_notes": 1, "enemy_types": 1},
	2: {"bpm": 118, "max_notes": 1, "enemy_types": 2},
	3: {"bpm": 118, "max_notes": 2, "enemy_types": 1},
	4: {"bpm": 118, "max_notes": 2, "enemy_types": 2},
	5: {"bpm": 138, "max_notes": 2, "enemy_types": 1},
	6: {"bpm": 138, "max_notes": 3, "enemy_types": 2},
	7: {"bpm": 138, "max_notes": 4, "enemy_types": 2},
}
@onready var player_health: int = MAX_HEALTH:
	get = get_health,
	set = set_health


func _ready() -> void:
	randomize()
	load_player_data()
	setup_leaderboard()


func set_velocity(new_speed: float) -> void:
	game_speed = new_speed


func get_velocity() -> float:
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


func set_health(new_health: int) -> void:
	player_health = new_health
	emit_signal("health_changed", player_health)
	if player_health <= 0:
		Global.is_game_over = true


func get_health() -> int:
	return player_health


func set_coins(new_coins: int) -> void:
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


func change_scene_to_file(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)


func set_highest_score() -> void:
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores().sw_get_scores_complete
	#print("Scores: " + str(sw_result.scores))
	highest_score = sw_result.scores[0]


func load_player_data() -> void:
	if not FileAccess.file_exists(SAVE_FILE):
		player_data = {"name": ""}
		save_player_data()

	var file: FileAccess = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if FileAccess.get_open_error():
		return
	player_data = file.get_var()


func save_player_data() -> void:
	var file: FileAccess = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if FileAccess.get_open_error():
		return
	file.store_var(player_data)


func setup_leaderboard() -> void:
	SilentWolf.configure(
		{"api_key": "<insert_api_key>", "game_id": "<insert_game_id>", "log_level": 1}
	)
	SilentWolf.configure_scores({"open_scene_on_close": "res://scenes/ui/menu.tscn"})
