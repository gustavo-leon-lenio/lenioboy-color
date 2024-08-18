extends Node2D

onready var main_menu: Control = $CanvasLayer/MainMenu
onready var leaderboard: Control = $CanvasLayer/Leaderboard

onready var main_menu_anim_player: AnimationPlayer = $CanvasLayer/MainMenu/AnimationPlayer
onready var name_input_dialog: AcceptDialog = $CanvasLayer/MainMenu/AcceptDialog
# gdlint: disable=max-line-length
onready var rich_text_label: RichTextLabel = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/HBoxContainer2/RichTextLabel
onready var play_button: Button = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/HBoxContainer/Play

onready var line_edit: LineEdit = $CanvasLayer/MainMenu/AcceptDialog/VBoxContainer/LineEdit
onready var ok_button: Button


func _ready() -> void:
	main_menu_anim_player.play("blink")
	ok_button = name_input_dialog.get_ok()
	Global.load_player_data()
	line_edit.text = Global.player_data.name
	toggle_ok_button(line_edit.text)
	rich_text_label.bbcode_text = bbcode_wrapper_effects(Global.player_data.name)


func is_alphanumeric_and_not_empty(text) -> bool:
	if text.empty():
		return false
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z0-9.]*$")
	return regex.search(text) != null


func bbcode_wrapper_effects(plain_text: String) -> String:
	return "[url=change_name][wave][rainbow freq=1.5 sat=0.5]%s[/rainbow][/wave][/url]" % plain_text


func on_leaderboard_pressed() -> void:
	leaderboard.visible = not leaderboard.visible


func on_rich_text_label_meta_clicked(meta) -> void:
	if meta == "change_name" and not leaderboard.visible:
		name_input_dialog.visible = true


func on_play_pressed() -> void:
	if not leaderboard.visible:
		if not Global.player_data.name:
			name_input_dialog.visible = true
		else:
			main_menu_anim_player.play("blink_fast")


func toggle_ok_button(new_text: String) -> void:
	ok_button.disabled = not is_alphanumeric_and_not_empty(new_text)


func on_line_edit_text_changed(new_text: String) -> void:
	toggle_ok_button(new_text)


func on_dialog_confirmed() -> void:
	Global.player_data.name = line_edit.text
	rich_text_label.bbcode_text = bbcode_wrapper_effects(Global.player_data.name)
	Global.save_player_data()


func start_game() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/game.tscn")
