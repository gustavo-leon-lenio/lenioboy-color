class_name Leni extends CharacterBody2D

const JUMP_HEIGHT: float = 38.0

@export var animated_sprite: AnimatedSprite2D
@export var animation_player: AnimationPlayer
@export var jump_audio_player: AudioStreamPlayer
@export var game_over_audio: AudioStreamPlayer
@export var fruit_sound: AudioStreamPlayer
@export var emote_sound: AudioStreamPlayer
@export var coyote_timer: Timer
@export var buffer_timer: Timer
@export var dust_particles: CPUParticles2D
@export var emote: Sprite2D
@export var hit_box_component: HitboxComponent
@export var run_collision_shape: CollisionShape2D
@export var fruit_pickup_popup: PackedScene
@export var popup_position: Marker2D
@export var camera: Camera2D
var camera_shake_noise: FastNoiseLite

var jump_time_to_peak: float = 0.25
var jump_time_to_descent: float = 0.10
var jump_velocity: float = 0.0
var jump_gravity: float = 0.0
var fall_gravity: float = 0.0
var is_crouching: bool = false
var took_damage: bool = false
var happy_emotes: Array[int] = [1, 4, 5, 6, 7, 9, 10, 11, 16, 24, 26]
var mad_emotes: Array[int] = [0, 2, 3, 14, 19, 21, 23, 27, 28, 29]
var was_airborne: bool = false

@onready var dust_scene: PackedScene = preload("res://scenes/dust.tscn")

@onready var happy_emote_sounds := [
	preload("res://assets/sounds/exclamations/all_right.wav"),
	preload("res://assets/sounds/exclamations/mmhumm.wav"),
	preload("res://assets/sounds/exclamations/oh_yeah.wav"),
	preload("res://assets/sounds/exclamations/this_is_awesome.wav"),
]

@onready var mad_emote_sounds := [
	preload("res://assets/sounds/exclamations/oopsie.wav"),
]

@onready var intervals_to_chord: Dictionary = {
	41: "G",
	45: "D",
	47: "C",
	49: "D",
	57: "G",
	60: "D",
	61: "Bm",
	63: "C",
	79: "D",
	116: "G",
	121: "D",
	123: "C",
	125: "D",
	126: "G",
}

@onready var jump_stream_files: Dictionary = {
	"C": $Chords/C,
	"G": $Chords/G,
	"D": $Chords/D,
	"Bm":$Chords/Bm,
	"Bb":$Chords/Bb,
}


func _ready() -> void:
	is_crouching = false
	Conductor.connect("beat", on_beat)
	Conductor.connect("tempo_changed", update_physics_parameters)
	Global.connect("game_over_changed", on_game_over)
	hit_box_component.connect("damage_taken", play_anim)
	camera_shake_noise = FastNoiseLite.new()


func get_chord_for_beat(beat:int) -> AudioStreamPlayer:
	for upper_bound: int in intervals_to_chord.keys():
		if beat <= upper_bound:
			return jump_stream_files[intervals_to_chord[upper_bound]] as AudioStreamPlayer
	return  jump_stream_files.G as AudioStreamPlayer

func on_beat(current_beat: int)-> void:
	jump_audio_player = get_chord_for_beat(current_beat)


func camera_shake(intensity: float) -> void:
	var camera_offset: float = camera_shake_noise.get_noise_1d(Time.get_ticks_msec()) * intensity
	camera.offset = Vector2(camera_offset, camera_offset)

func _physics_process(delta: float) -> void:
	if not Global.is_game_over:
		if Input.is_action_just_pressed("jump") and !is_crouching:
			buffer_timer.start()

		if is_on_floor():
			if was_airborne:
				was_airborne = false
				animated_sprite.scale = Vector2(1.3, 0.7)
				dust_particles.emitting = true
				var dust_instance: AnimatedSprite2D = dust_scene.instantiate() as AnimatedSprite2D
				dust_instance.global_position = animated_sprite.global_position
				get_parent().add_child(dust_instance)

			if !is_crouching:
				animated_sprite.play("run")
			else:
				animated_sprite.scale = Vector2(1.4, 0.6)
			coyote_timer.start()

			if Input.is_action_pressed("crouch") and !is_crouching:
				is_crouching = true
				animated_sprite.play("crouch")
				run_collision_shape.disabled = true
			if Input.is_action_just_released("crouch") and is_crouching:
				is_crouching = false
				run_collision_shape.disabled = false
			if not buffer_timer.is_stopped():
				jump()

		else:
			was_airborne = true
			if coyote_timer.is_stopped():
				_apply_gravity(delta)
			elif not buffer_timer.is_stopped():
				jump()

		if velocity.y > 0:
			animated_sprite.play("fall")

		move_and_slide()
		animated_sprite.scale.x = move_toward(animated_sprite.scale.x, 1, 1.6 * delta)
		animated_sprite.scale.y = move_toward(animated_sprite.scale.y, 1, 1.6 * delta)


func jump() -> void:
	dust_particles.emitting = false
	jump_audio_player.play()
	animated_sprite.scale = Vector2(0.7, 1.3)
	animated_sprite.play("jump")
	velocity.y = jump_velocity
	buffer_timer.stop()
	coyote_timer.stop()


func update_physics_parameters(_tempo: int, _bar_length: float, game_speed: float) -> void:
	dust_particles.initial_velocity_max = game_speed * 0.20
	jump_time_to_peak = 37.5 / game_speed
	jump_time_to_descent = 24.0 / game_speed
	jump_velocity = 2.0 * JUMP_HEIGHT / jump_time_to_peak * -1.0
	jump_gravity = -2.0 * JUMP_HEIGHT / (jump_time_to_peak * jump_time_to_peak) * -1.0
	fall_gravity = -2.0 * JUMP_HEIGHT / (jump_time_to_descent * jump_time_to_descent) * -1.0


func _apply_gravity(delta: float) -> void:
	velocity.y += _get_gravity() * delta


func _get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity


func _emote(sad: bool = false) -> void:
	var emote_array: Array = mad_emotes if sad else happy_emotes
	emote_sound.stream = (
		(
			mad_emote_sounds[randi() % mad_emote_sounds.size()]
			if sad
			else happy_emote_sounds[randi() % happy_emote_sounds.size()]
		)
		as AudioStream
	)

	emote.frame = emote_array[randi() % emote_array.size()]
	emote_sound.play()
	if not Global.is_game_over:
		if sad:
			took_damage = true
			animation_player.play("damage")

		emote.visible = true
		await get_tree().create_timer(1).timeout
		emote.visible = false


func on_obstacle_area_exited(area: Area2D) -> void:
	var is_high: bool = area.global_position.y < 155.5

	if not took_damage and not Global.is_game_over:
		if area.is_in_group("bird") and is_high:
			_emote()
		elif area.is_in_group("flag"):
			_emote()


func on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("fruit"):
		fruit_sound.play()
		var fruit_popup: Marker2D = fruit_pickup_popup.instantiate()
		fruit_popup.position =  popup_position.global_position
		get_tree().current_scene.add_child(fruit_popup)
		area.queue_free()


func on_game_over(new_value: bool) -> void:
	camera.enabled = new_value
	if not new_value:
		animated_sprite.play("run")
	elif new_value:
		_emote(new_value)
		animated_sprite.play("dead")
		await get_tree().create_timer(0.6).timeout
		self.process_mode = PROCESS_MODE_ALWAYS
		play_dead_animation()


func play_dead_animation() -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(camera_shake, 4.0, 1.0, 0.3)
	tween.parallel()
	game_over_audio.play()
	tween.tween_property(self, "position", Vector2.UP * 20, 0.3).as_relative()
	tween.tween_property(self, "position", Vector2.DOWN * 300, 0.3).as_relative().from_current()
	await tween.finished
	self.process_mode = PROCESS_MODE_INHERIT
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")


func play_anim() -> void:
	_emote(true)


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	took_damage = false
