extends Control

const TOP_AMOUNT: int = 7
var node_references: Array
onready var loading_panel: Panel = $VBoxContainer/LoadingPanel
onready var score_list_container: VBoxContainer = $VBoxContainer
onready var player_score_item: PackedScene = preload("res://scenes/ui/player_list_item.tscn")
onready var refresh_button: TextureButton = $VBoxContainer/HBoxContainer/Refresh


func get_top_scores():
	refresh_button.disabled = true
	for row in node_references:
		row.queue_free()
	node_references.clear()
	loading_panel.visible = true
	yield(SilentWolf.Scores.get_high_scores(TOP_AMOUNT), "sw_scores_received")

	for i in range(SilentWolf.Scores.scores.size()):
		add_row(SilentWolf.Scores.scores[i], i + 1)
	loading_panel.visible = false
	refresh_button.disabled = false


func refresh():
	get_top_scores()


func add_row(score_item: Dictionary, index: int) -> void:
	var row_instance = player_score_item.instance()

	var rank_label = row_instance.get_node("Rank")
	var score_label = row_instance.get_node("Score")
	var name_label = row_instance.get_node("Name")

	rank_label.text = str(index)
	score_label.text = str("%.2f" % score_item.score)
	name_label.text = score_item.player_name
	node_references.append(row_instance)
	score_list_container.add_child(row_instance)


func on_leaderboard_visibility_changed() -> void:
	if self.visible:
		refresh()


func on_back_pressed() -> void:
	self.visible = false
