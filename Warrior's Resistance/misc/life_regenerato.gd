extends Node2D

@export var regenerated_amount: int= 10

func _ready():
	$Area2D.body_entered.connect(on_body_entered) #quando um corpo entra na area

func on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		var player: Player = body
		player.heal(regenerated_amount)
		player.meat_collected.emit(regenerated_amount)
		queue_free()

