extends AudioStreamPlayer

# Signals to emit on each beat and when the tempo changes.
@warning_ignore("unused_signal")
signal beat(song_beat: int)
@warning_ignore("unused_signal")
signal distractor_beat_signal
@warning_ignore("unused_signal")
signal tempo_changed(new_tempo: int, new_bar_length: float, game_speed: float)

const DISTRACTOR_BEAT_OFFSET = 1
# Number of measures in a bar. 4/4
var measures: int = 4
var distractor_beat: int

# Length of a bar in the game. [----|----|----|----]
var bar_length: float
# Current position in the song.
var song_position: float = 0.0
# Current position in the song in terms of beats.
var song_position_in_beats: int = 0
# Seconds per beat, based on the tempo.
var sec_per_beat: float
# The last beat that was reported.
var last_reported_beat: int = 0
# Beats before the start of the song.
var beats_before_start: int = 0
# Property for setting and getting the tempo.
var tempo: int = 100:
	get = get_tempo,
	set = set_tempo

# Preloaded audio streams for different tempos.
@onready var stream_files: Dictionary = {
	100: preload("res://assets/sounds/music/music_100_short.wav"),
	118: preload("res://assets/sounds/music/music_118.wav"),
	138: preload("res://assets/sounds/music/music_138.wav")
}

func _ready() -> void:
	Global.connect("game_over_changed", stop_music)
	for audio_index: int in stream_files:
		AudioServer.register_stream_as_sample(stream_files[audio_index])
	set_physics_process(false)
	volume_db = -10

func get_tempo() -> int:
	return tempo


func set_tempo(new_value: int) -> void:
	tempo = new_value
	sec_per_beat = 60.0 / tempo  # Calculate seconds per beat.
	bar_length = 2.40 * tempo  # Calculate bar length.
	Global.game_speed = bar_length / (measures * sec_per_beat)
	stream = stream_files[tempo]  # Set the audio stream based on the tempo.
	emit_signal("tempo_changed", tempo, bar_length, Global.game_speed)
	reset_params()  # Reset parameters for the new tempo.


func reset_params() -> void:
	# Reset the last reported beat.
	last_reported_beat = 0


func _physics_process(_delta: float) -> void:
	# Update song position and beats during the physics process.
	if self and playing:
		song_position = get_playback_position() + AudioServer.get_time_since_last_mix()
		song_position -= AudioServer.get_output_latency()
		song_position_in_beats = int(floor(song_position / sec_per_beat)) + beats_before_start
		_report_beat()


func _report_beat() -> void:
	# Emit a beat signal if a new beat is reached.
	if last_reported_beat < song_position_in_beats:
		emit_signal("beat", song_position_in_beats)
		if song_position_in_beats == distractor_beat:
			emit_signal("distractor_beat_signal")

		last_reported_beat = song_position_in_beats


func play_from_beat(_beat: int, offset: int = 0) -> void:
	# Play the audio stream from a specific beat.
	distractor_beat = randi() % 10 + DISTRACTOR_BEAT_OFFSET
	play()
	seek(_beat * sec_per_beat)
	beats_before_start = offset


func stop_music(is_game_over: bool) -> void:
	if is_game_over:
		stop()
