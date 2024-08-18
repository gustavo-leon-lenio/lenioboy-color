extends ParallaxBackground

@export var timer: Timer
@export var palette: ColorRect

var current_color_index: int = 0
var cached_speed: float

var color_set: Dictionary = {
    0:  #day
    [
        Color(0.318, 0.671, 0.886, 1),
        Color(1, 1, 1, 1),
        Color(0.80, 0.51, 0.37, 1),
        Color(0.714, 0.835, 0.235, 1),
        Color(0.443, 0.667, 0.204, 1.0)
    ],
    1:
    [  #sunset
        Color(0.93, 0.38, 0.34, 1),
        Color(0.90, 0.56, 0.02, 1),
        Color(0.77, 0.25, 0.53, 1),
        Color(0.21, 0.03, 0.41, 1),
        Color(0.47, 0.32, 0.59, 1.0)
    ],
    2:
    [  #night
        Color(0.021, 0.071, 0.074, 1),
        Color(0.721, 0.931, 1, 1),
        Color(0.292, 0.208, 0.294, 1),
        Color(0.777, 0.693, 0.995, 1),
        Color(0.071, 0.032, 0.101, 1.0)
    ],
}


func _ready() -> void:
    cached_speed = Global.get_velocity()
    Global.connect("change_speed", set_velocity)
    Global.connect("level_changed", on_level_changed)
    timer.connect("timeout", change_palette)


func set_velocity(new_speed: float) -> void:
    cached_speed = new_speed


func _process(delta: float) -> void:
    scroll_offset.x += Global.get_velocity() * delta


func change_palette() -> void:
    current_color_index += 1
    current_color_index %= 3
    for color: int in color_set[current_color_index].size():
        var shader_param_name: String = "to_color%s" % str(color + 1)
        var tween: Tween = create_tween()
        tween.set_trans(Tween.TRANS_BOUNCE)
        tween.set_parallel()
        _create_shader_tween(
            tween,
            palette,
            shader_param_name,
            palette.material.get_shader_parameter(shader_param_name),
            color_set[current_color_index][color]
        )


func _create_shader_tween(
    tween: Tween,
    node: Node,
    shader_property: String,
    value_start: Variant,
    value_end: Variant,
    duration: float = 1
) -> Tween:
    tween.tween_method(
        func(value: Variant) -> void: node.material.set_shader_parameter(shader_property, value),
        value_start,
        value_end,
        duration
    )
    return tween


func on_level_changed(_new_level: int) -> void:
    if _new_level == 2:
       timer.start()
