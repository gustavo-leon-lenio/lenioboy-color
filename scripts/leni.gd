class_name Leni
extends KinematicBody2D

const JUMP_HEIGHT: float = 38.0
var velocity: Vector2 = Vector2.ZERO
var jump_time_to_peak: float = 0.25
var jump_time_to_descent: float = 0.10
var jump_velocity: float = 0.0
var jump_gravity: float = 0.0
var fall_gravity: float = 0.0
var is_crouching: bool = false
var took_damage: bool = false
var happy_emotes := [1, 4, 5, 6, 7, 9, 10, 11, 16, 24, 26]
var mad_emotes := [0, 2, 3, 14, 19, 21, 23, 27, 28, 29]

onready var animated_sprite: AnimatedSprite = $AnimatedSprite
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var jump_audio_player: AudioStreamPlayer = $JumpSound
onready var game_over_audio: AudioStreamPlayer = $GameOver
onready var fruit_sound: AudioStreamPlayer = $FruitSoundPlayer
onready var emote_sound: AudioStreamPlayer = $EmoteSound
onready var coyote_timer: Timer = $CoyoteTimer
onready var buffer_timer: Timer = $BufferTimer
onready var dust_particles: CPUParticles2D = $CPUParticles2D
onready var emote: Sprite = $Sprite

onready var run_collision_shape: CollisionShape2D = $HitboxComponent/Run
onready var hit_box_component: HitboxComponent = $HitboxComponent

onready var happy_emote_sounds := [
	preload("res://assets/sounds/exclamations/all_right.wav"),
	preload("res://assets/sounds/exclamations/mmhumm.wav"),
	preload("res://assets/sounds/exclamations/oh_yeah.wav"),
	preload("res://assets/sounds/exclamations/this_is_awesome.wav"),
]

onready var mad_emote_sounds := [
	preload("res://assets/sounds/exclamations/oopsie.wav"),
]


func _ready() -> void:
	self.pause_mode = PAUSE_MODE_INHERIT
	# warning-ignore:return_value_discarded
	Conductor.connect("tempo_changed", self, "update_physics_parameters")
	# warning-ignore:return_value_discarded
	Global.connect("game_over_changed", self, "on_game_over")
	# warning-ignore:return_value_discarded
	hit_box_component.connect("damage_taken", self, "play_anim")


func _physics_process(delta):
	if not Global.is_game_over:
		if Input.is_action_just_pressed("jump") and !is_crouching:
			buffer_timer.start()

		if is_on_floor():
			dust_particles.emitting = true
			if !is_crouching:
				animated_sprite.play("run")
			coyote_timer.start()

			if Input.is_action_pressed("ui_down") and !is_crouching:
				is_crouching = true
				animated_sprite.play("crouch")
				run_collision_shape.disabled = true
			if Input.is_action_just_released("ui_down") and is_crouching:
				is_crouching = false
				run_collision_shape.disabled = false
			if not buffer_timer.is_stopped():
				jump()
		else:
			if coyote_timer.is_stopped():
				_apply_gravity(delta)
			elif not buffer_timer.is_stopped():
				jump()

		if velocity.y > 0:
			animated_sprite.play("fall")

		velocity = move_and_slide(velocity, Vector2.UP)


func jump():
	dust_particles.emitting = false
	jump_audio_player.play()
	animated_sprite.play("jump")
	velocity.y = jump_velocity
	buffer_timer.stop()
	coyote_timer.stop()


func update_physics_parameters(_tempo: int, _bar_length: float, game_speed: float):
	dust_particles.initial_velocity = game_speed * 0.20
	jump_time_to_peak = 37.5 / game_speed
	jump_time_to_descent = 24.0 / game_speed
	jump_velocity = 2.0 * JUMP_HEIGHT / jump_time_to_peak * -1.0
	jump_gravity = -2.0 * JUMP_HEIGHT / (jump_time_to_peak * jump_time_to_peak) * -1.0
	fall_gravity = -2.0 * JUMP_HEIGHT / (jump_time_to_descent * jump_time_to_descent) * -1.0


func _apply_gravity(delta):
	velocity.y += _get_gravity() * delta


func _get_gravity():
	return jump_gravity if velocity.y < 0.0 else fall_gravity


func _emote(sad: bool = false) -> void:
	var emote_array = mad_emotes if sad else happy_emotes
	emote_sound.stream = (
		mad_emote_sounds[randi() % mad_emote_sounds.size()]
		if sad
		else happy_emote_sounds[randi() % happy_emote_sounds.size()] as AudioStream
	)

	emote.frame = emote_array[randi() % emote_array.size()]
	emote_sound.play()
	if not Global.is_game_over:
		if sad:
			took_damage = true
			animation_player.play("damage")

		emote.visible = true
		yield(get_tree().create_timer(1), "timeout")
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
		area.queue_free()


func on_game_over(new_value: bool) -> void:
	if not new_value:
		animated_sprite.play("run")
	elif new_value:
		_emote(new_value)
		animated_sprite.play("dead")
		yield(get_tree().create_timer(0.6), "timeout")
		self.pause_mode = PAUSE_MODE_PROCESS
		play_dead_animation()


func play_dead_animation() -> void:
	var tween: SceneTreeTween = create_tween()
	# warning-ignore:return_value_discarded
	tween.set_trans(Tween.TRANS_SINE)
	# warning-ignore:return_value_discarded
	tween.set_ease(Tween.EASE_IN_OUT)
	game_over_audio.play()
	# warning-ignore:return_value_discarded
	tween.tween_property(self, "position", Vector2.UP * 20, 0.3).as_relative()
	# warning-ignore:return_value_discarded
	tween.tween_property(self, "position", Vector2.DOWN * 300, 0.3).as_relative().from_current()
	yield(tween, "finished")
	self.pause_mode = PAUSE_MODE_INHERIT
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/game_over.tscn")


func play_anim() -> void:
	_emote(true)


func on_animation_player_finished(_anim_name: String) -> void:
	took_damage = false
