extends Node2D

const SCORE_MODIFIER: int = 10000

@export var parallax_background: ParallaxBackground
@export var score_label: Label
@export var level_start_label: Label
@export var level_up_sound_player: AudioStreamPlayer

var cached_speed: float


func _ready() -> void:
	cached_speed = Global.get_velocity()
	Global.connect("game_over_changed", set_game_over)
	Global.connect("change_speed", set_velocity)
	Global.connect("level_changed", play_level_start_label)
	Conductor.connect("finished", on_conductor_finished)
	Conductor.set_physics_process(true)
	Conductor.reset_params()

	Global.game_score = 0
	Global.level = 1
	Global.is_game_over = false
	Conductor.tempo = Global.level_list[Global.level].bpm
	Conductor.play_from_beat(0)


func set_velocity(new_speed: float) -> void:
	cached_speed = new_speed


func show_score() -> void:
	score_label.text = str("%.2f" % Global.game_score)


func on_conductor_finished() -> void:
	# When a song finishes, move to the next level and update the tempo.
	Global.level = int(clamp(Global.level + 1, 1, Global.level_list.size()))
	Conductor.tempo = Global.level_list[Global.level].bpm
	Conductor.play_from_beat(0)


func _physics_process(_delta: float) -> void:
	Global.game_score += cached_speed / SCORE_MODIFIER
	show_score()


func set_game_over(new_value: bool) -> void:
	get_tree().paused = new_value


func play_level_start_label(new_level: int) -> void:
	if new_level > 1:
		level_up_sound_player.play()
	level_start_label.text = "level %s" % str(new_level) if new_level > 1 else "Game Start"
	level_start_label.scale = Vector2(1, 1)
	level_start_label.visible = true
	await get_tree().create_timer(1.3).timeout
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(level_start_label, "scale", Vector2(0, 0), 1.5).from_current()
	await tween.finished
	level_start_label.visible = false
	level_start_label.scale = Vector2(1, 1)



