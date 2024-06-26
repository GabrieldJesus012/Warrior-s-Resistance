class_name MobSpawner
extends Node2D

@export var creatures: Array[PackedScene] # e arrastrei os mobs criados para ele
var mobs_por_minuto:float= 60.0

@onready var path_follow_2d: PathFollow2D = %PathFollow2D
var cooldown: float = 0.0

func _process(delta:float):
	#ignorar caso gameover
	if GameManager.is_game_over: return
	
	#temporarizador(coodown)
	cooldown-=delta
	if cooldown>0: return
	
	#frequencia: Monstros por minuto
	var interval = 60.0/ mobs_por_minuto
	cooldown= interval
	
	#checar se o lugar é valido
	var point = get_point()
	var world_state= get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = point
	parameters.collision_mask = 0b1001
	var result: Array = world_state.intersect_point(parameters, 1)
	if not result.is_empty(): return
	
	#Instanciar uma criatura aleatoria
	var index= randi_range(0, creatures.size()-1)
	var creature_scene = creatures[index]
	var creature = creature_scene.instantiate()
	creature.global_position = point
	get_parent().add_child(creature)

func get_point() -> Vector2:
	path_follow_2d.progress_ratio = randf() #retornar valor aleatorio
	return path_follow_2d.global_position
