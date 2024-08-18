extends ParallaxBackground

var current_color_index: int = 0
var cached_speed: float


func _ready() -> void:
	cached_speed = Global.get_speed()
	# warning-ignore:return_value_discarded
	Global.connect("change_speed", self, "set_speed")


func set_speed(new_speed: float) -> void:
	cached_speed = new_speed


func _process(delta: float) -> void:
	scroll_offset.x += Global.get_speed() * delta
