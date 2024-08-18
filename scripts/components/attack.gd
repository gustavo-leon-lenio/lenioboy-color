class_name Attack

var attack_damage: int
var knockback_force: float
var attack_position: Vector2


func _init(
	_attack_damage: int,
	_knockback_force: float = 0,
	_attack_position: Vector2 = Vector2(),
) -> void:
	attack_damage = _attack_damage
	knockback_force = _knockback_force
	attack_position = _attack_position
