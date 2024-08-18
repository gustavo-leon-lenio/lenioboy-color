class_name HealthComponent
extends Node2D

@export var max_health: int = 2
@export var main_player: bool = false
var health: int


func _ready() -> void:
	health = max_health
	if main_player:
		Global.player_health = health


func damage(attack: Attack) -> void:
	health -= attack.attack_damage
	health = clamp(health, 0, max_health)

	if main_player:
		Global.player_health = health
	elif not main_player and health <= 0:
		get_parent().queue_free()


func heal(_heal: Heal) -> void:
	health += _heal.heal_amount
	health = clamp(health, 0, max_health)
	if main_player:
		Global.player_health = health
