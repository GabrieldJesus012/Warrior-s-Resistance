extends Node2D

@export var demage_amount: int = 0

@onready var area2D: Area2D = $Area2D

func _process(delta):
	var bodies = area2D.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			if enemy.position < GameManager.player_position:
				enemy.push(Vector2(10, 10))
			elif enemy.position > GameManager.player_position:
				enemy.push(Vector2(-10, -10))
