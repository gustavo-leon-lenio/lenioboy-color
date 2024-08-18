class_name HealthComponent
extends Node2D

export var MAX_HEALTH: int = 2
export var main_player: bool = false
var health: int


func _ready() -> void:
	health = MAX_HEALTH
	if main_player:
		Global.player_health = health


func damage(attack: Attack) -> void:
	health -= attack.attack_damage
	# warning-ignore:narrowing_conversion
	health = clamp(health, 0, MAX_HEALTH)

	if main_player:
		Global.player_health = health
	elif not main_player and health <= 0:
		get_parent().queue_free()


func heal(heal: Heal) -> void:
	health += heal.heal_amount
	# warning-ignore:narrowing_conversion
	health = clamp(health, 0, MAX_HEALTH)
	if main_player:
		Global.player_health = health
