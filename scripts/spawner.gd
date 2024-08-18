class_name Spawner
extends Node2D

var previous_bar_length = 0
var song_track: Array = []

onready var bottom_spawner: Position2D = $Bottom
onready var top_spawners = [$MinTop, $MaxTop]
onready var spawn_reference: Position2D = get_parent().get_node_or_null("RefPosition")
onready var ground_obstacles = [
	preload("res://scenes/obstacles/timtom.tscn"),
	preload("res://scenes/obstacles/kacti.tscn"),
	preload("res://scenes/obstacles/awty.tscn"),
	preload("res://scenes/obstacles/chubly.tscn"),
]

onready var top_obstacles = [
	preload("res://scenes/obstacles/alby.tscn"),
]

onready var goodies = [preload("res://scenes/goodies/fruit.tscn")]

onready var finals = [preload("res://scenes/goodies/flag.tscn")]

onready var probability = 0.08


func _ready() -> void:
	randomize()
	#warning-ignore:return_value_discarded
	Conductor.connect("tempo_changed", self, "on_tempo_changed")
	#warning-ignore:return_value_discarded
	Conductor.connect("beat", self, "on_beat")


func on_tempo_changed(_tempo: int, bar_length: float, _game_speed: float) -> void:
	if previous_bar_length != bar_length:
		spawn_reference.global_position.x -= 5 if bar_length > 240 else 0
	previous_bar_length = bar_length
	position = spawn_reference.global_position - Vector2(bar_length, 0)
	var max_notes: int = Global.level_list[Global.level].max_notes
	var enemy_types: int = Global.level_list[Global.level].enemy_types
	song_track = LevelGenerator.generate_rhythm(max_notes, enemy_types)


func get_array_based_on_modulo(_measure: int) -> Array:
	var result = [0, 0, 0, 0]
	var modulo: int = _measure % 4
	result[modulo] = 1
	return result


func on_beat(song_position_in_beats: int) -> void:
	spawn_note(song_track[song_position_in_beats - 1])


func spawn_note(to_spawn: int) -> void:
	if to_spawn == 0:
		return

	var obstacle_pool
	var obstacle_pos: Vector2
	var scene_spawned: Node
	if to_spawn > 0:
		obstacle_pool = select_obstacle_pool(to_spawn)
		scene_spawned = obstacle_pool[randi() % obstacle_pool.size()].instance()

		obstacle_pos = get_obstacle_position(to_spawn)
		scene_spawned.position = obstacle_pos
		get_parent().add_child(scene_spawned)


func select_obstacle_pool(selected_pool: int) -> Array:
	var pool = []
	match selected_pool:
		LevelGenerator.PoolType.FLAG:
			pool = finals
		LevelGenerator.PoolType.NORMAL:
			pool = ground_obstacles
		LevelGenerator.PoolType.BIRD:
			pool = top_obstacles
		LevelGenerator.PoolType.GOODIE:
			pool = goodies
	return pool


func get_obstacle_position(to_spawn: int) -> Vector2:
	if to_spawn == LevelGenerator.PoolType.BIRD:
		return Vector2(
			bottom_spawner.global_position.x,
			rand_range(top_spawners[1].global_position.y, top_spawners[0].global_position.y)
		)
	return bottom_spawner.global_position
