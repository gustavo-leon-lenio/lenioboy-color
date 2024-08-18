extends CanvasLayer

var _last_level: int

@onready var shader_rect_parent: Control = $Shaders
@onready var scan_lines_rect: ColorRect = $Shaders/ScanLines
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var crt_vhs_rect: ColorRect = $Shaders/CRTVHS
@onready var crt_vhs_material: Material

@onready var crt_vhs_defaults: Dictionary = {
	"overlay": true,
	"scanlines_opacity": 0.164,
	"scanlines_width": 0.116,
	"static_noise_intensity": 0.06
}


func _ready() -> void:
	reset_audio_effects()
	reset_shader_rect_children(true)
	Global.connect("level_changed", on_level_changed)
	crt_vhs_material = crt_vhs_rect.material


func reset_shader_rect_children(is_game_over: bool) -> void:
	if is_game_over:
		reset_crt_vhs_shader()
		#for child in shader_rect_parent.get_children():
		#child.visible = false
		#child.self_modulate = Color(1, 1, 1, 1)


func reset_crt_vhs_shader() -> void:
	if crt_vhs_material is ShaderMaterial:
		for param_name: String in crt_vhs_defaults.keys():
			crt_vhs_material.set_shader_parameter(param_name, crt_vhs_defaults[param_name])


func set_crt_vhs_level(crt_level: int) -> void:
	match crt_level:
		6:
			crt_vhs_material.set_shader_parameter("static_noise_intensity", 0.5)
		7:
			crt_vhs_material.set_shader_parameter("static_noise_intensity", 0.6)


func set_old_handheld_audio_effects() -> void:
	var bandpass: AudioEffectBandPassFilter = AudioEffectBandPassFilter.new()
	bandpass.cutoff_hz = 5000

	var distortion: AudioEffectDistortion = AudioEffectDistortion.new()
	distortion.mode = AudioEffectDistortion.MODE_CLIP
	distortion.drive = 0.2
	AudioServer.add_bus_effect(0, bandpass)
	AudioServer.add_bus_effect(0, distortion)


func reset_audio_effects() -> void:
	# Get the number of effects on the bus
	var num_effects: int = AudioServer.get_bus_effect_count(0)

	# Remove all effects
	for _i in range(num_effects):
		# Always remove the first effect (since the indices shift after each removal)
		AudioServer.remove_bus_effect(0, 0)


func on_level_changed(new_level: int) -> void:
	_last_level = new_level
	match new_level:
		3:
			animation_player.play("scan_lines")
		4:
			animation_player.play("crt_vhs_1")
			set_old_handheld_audio_effects()
		5:
			set_crt_vhs_level(new_level)
			set_old_handheld_audio_effects()
		6:
			animation_player.play("game_boy")
			set_crt_vhs_level(new_level)
			set_old_handheld_audio_effects()
		7:
			animation_player.play("static")

	_last_level = new_level
