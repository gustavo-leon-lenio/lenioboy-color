extends Control

const TOP_AMOUNT: int = 7
@export var loading_panel: Panel
@export var score_list_container: VBoxContainer
@export var refresh_button: TextureButton

var node_references: Array[Node]

@onready var player_score_item: PackedScene = preload("res://scenes/ui/player_list_item.tscn")


func get_top_scores() -> void:
    refresh_button.disabled = true
    for row: Node in node_references:
        row.queue_free()
    node_references.clear()
    loading_panel.visible = true
    var sw_result: Dictionary = await SilentWolf.Scores.get_scores(0).sw_get_scores_complete

    for i in range(sw_result.scores.size()):
        add_row(sw_result.scores[i], i + 1)
    loading_panel.visible = false
    refresh_button.disabled = false


func refresh() -> void:
    get_top_scores()


func add_row(score_item: Dictionary, index: int) -> void:
    var row_instance: HBoxContainer = player_score_item.instantiate()

    var rank_label: Label = row_instance.get_node("Rank")
    var score_label: Label = row_instance.get_node("Score")
    var name_label: Label = row_instance.get_node("Name")

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
