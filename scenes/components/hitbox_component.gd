class_name HitboxComponent
extends Area2D

@warning_ignore("unused_signal")
signal damage_taken

@export var health_component: HealthComponent


func damage(attack: Attack) -> void:
	if health_component:
		health_component.damage(attack)
		self.emit_signal("damage_taken")


func heal(_heal: Heal) -> void:
	if health_component:
		health_component.heal(_heal)
