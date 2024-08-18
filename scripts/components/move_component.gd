class_name MovementComponent
extends Node2D
@export var move: bool = false

var cached_speed: float
@onready var parent_node: Node = get_parent()


func _ready() -> void:
	cached_speed = Global.get_velocity()
	# warning-ignore:return_value_discarded
	Global.connect("change_speed", Callable(self, "set_velocity"))


func set_velocity(new_speed: float) -> void:
	cached_speed = new_speed


func _process(delta: float) -> void:
	parent_node.position.x += cached_speed * delta
