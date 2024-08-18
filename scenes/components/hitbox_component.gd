class_name HitboxComponent
extends Area2D

signal damage_taken

onready var health_component: HealthComponent = $"../HealthComponent"


func damage(attack: Attack) -> void:
	if health_component:
		health_component.damage(attack)
		emit_signal("damage_taken")


func heal(heal: Heal) -> void:
	if health_component:
		health_component.heal(heal)
