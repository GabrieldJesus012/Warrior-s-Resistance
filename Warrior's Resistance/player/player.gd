class_name Player
extends CharacterBody2D

@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var sprite:Sprite2D = $Sprite2D
@onready var sword_area: Area2D =$SwordArea
@onready var hitbox_area: Area2D =$HitboxArea
@onready var health_progress_bar: ProgressBar = $HeathProgressBar


@export_category("Movement")
@export var speed: float = 3
@export_category("Sword")
@export var sword_damage: int = 2
@export_category("Poderes")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30
@export var ritual_scene: PackedScene
@export var pushing_scene: PackedScene
@export_category("Life")
@export var health: int= 50
@export var max_health: int = 100
@export var death_prefab: PackedScene

#Variaveis
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float =0.0
var hitbox_cooldown: float= 0.0
var input_vector: Vector2 = Vector2(0,0)
var ritual_cooldown: float= 0.0
var push_cooldown_timer: Timer
var newDir: Vector2 = Vector2.ZERO

signal  meat_collected(value:int)

#Funcoes:

func _ready():
	GameManager.player = self
	meat_collected.connect(func(value:int):GameManager.meat_count +=1)
	#push tempo
	push_cooldown_timer = Timer.new()
	push_cooldown_timer.wait_time = 25.0  # Tempo de cooldown em segundos
	push_cooldown_timer.one_shot = true
	add_child(push_cooldown_timer)

func _process(delta:float) -> void:
	GameManager.player_position = position
	
	ready_input()
	
	#Processar ataque
	uptade_attack_cooldown(delta)
	if Input.is_action_just_pressed("attack"): #A gente acabou de atacar?
		attack()
		
	#processar animação e rotação de sprite
	play_run_iddle_animation()
	if not is_attacking:
		rotate_sprite()
	
	#Processar dano
	uptade_hitbox_detection(delta)
	
	#Ritual
	update_ritual(delta)
	
	#atualizar HeathBar
	health_progress_bar.max_value = max_health
	health_progress_bar.value= health

func _physics_process(delta:float) -> void:
	#modificar a velocidade
	var target_velocity = input_vector * speed * 100.0
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp (velocity,target_velocity,0.05)
	move_and_slide()

func uptade_attack_cooldown(delta:float)->void:
	if is_attacking:
		attack_cooldown -=delta #0.6 - 0.016
		if attack_cooldown<=0.0:
			is_attacking = false
			is_running = false
			animation_player.play("Idle")

func ready_input() -> void:
	#obter o input vector
	input_vector= Input.get_vector("move_left","move_right","move_up","move_down")
	
	#Apagar deadzone do Input Vector
	var deadzone = 0.15
	if abs(input_vector.x)<0.15:
		input_vector.x = 0.0
	if abs(input_vector.y)<0.15:
		input_vector.y = 0.0
	
	#atualizar o is running
	was_running = is_running
	is_running= not input_vector.is_zero_approx() #checar se o valor é zero (se nao é 0 ta correndo)

func play_run_iddle_animation() -> void:
	#Tocar animação
	if not is_attacking:
		if was_running != is_running: 
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("Idle")

func rotate_sprite()->void:
	#girar sprite
	if input_vector.x>0:
		sprite.flip_h= false
		#desmarcar flip H
	elif input_vector.x<0:
		sprite.flip_h= true
		#marcar flip H

func attack() -> void:
	#attack_side_1 e #attack_side_2 (as animações que criamos)
	if is_attacking:
		return
	
	#tocar animação de atack
	# Verificar se o jogador está se movendo para cima
	if input_vector.y < 0:
	# Escolher aleatoriamente entre attack_up_1 e attack_up_2
		var random_attack = randi() % 2
		if random_attack == 0:
			animation_player.play("attack_up_1")
		else:
			animation_player.play("attack_up_2")
	elif input_vector.y > 0:
		# Escolher aleatoriamente entre attack_down_1 e attack_down_2
		var random_attack = randi() % 2
		if random_attack == 0:
			animation_player.play("attack_down_1")
		else:
			animation_player.play("attack_down_2")
	else:
	# Escolher aleatoriamente entre attack_side_1 e attack_side_2
		var random_attack = randi() % 2
		if random_attack == 0:
			animation_player.play("attack_side_1")
		else:
			animation_player.play("attack_side_2")
	
	attack_cooldown= 0.6
	
	# Marcar ataque
	is_attacking = true

func deal_damage_to_enemies() -> void:
	var bodies= sword_area.get_overlapping_bodies() #pegar todos os corpos fisicos da area
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			#calcular direção do inimigo para personagem
			var direction_to_enemy=(enemy.position-position).normalized()  #normalized= 1 de comprimento
			var attack_direction: Vector2
			if input_vector.y < 0: # Ataque para cima
				attack_direction = Vector2.UP
			elif input_vector.y > 0:  # Ataque para baixo
				attack_direction = Vector2.DOWN
			else:
				if sprite.flip_h:
					attack_direction = Vector2.LEFT
				else:
					attack_direction = Vector2.RIGHT
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >=0.3:
				enemy.damage(sword_damage)

func uptade_hitbox_detection(delta:float):
	#temporarizador
	hitbox_cooldown-= delta
	if hitbox_cooldown >0: return
	
	#frequencia
	hitbox_cooldown = 0.5
	
	#detectar inimigo
	var bodies= hitbox_area.get_overlapping_bodies() #pegar todos os corpos fisicos da area
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount)

func damage(amount: int)-> void:
	if health<=0: return
	
	health-= amount
	
	#piscar node
	modulate= Color.RED
	var tween= create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	#processar morte
	if health <=0:
		die()

func die():
	GameManager.end_game()
	
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	queue_free()

func heal(amount:int):
	health += amount
	if health> max_health:
		health = max_health
	return health

func update_ritual(delta:float):
	#atualizar tempo
	ritual_cooldown-=delta
	if ritual_cooldown>0: return
	ritual_cooldown = ritual_interval
	
	#criar o ritual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)

func _input(event: InputEvent) -> void:
		if Input.is_action_pressed("play_push"):
				if GameManager.p_on == false and push_cooldown_timer.is_stopped():
					pushing()
					GameManager.p_on = true
					push_cooldown_timer.start()
					GameManager.emit_signal("play_push_animation")
					await push_cooldown_timer.timeout
					GameManager.p_on = false  # Reseta o estado do push

func pushing():
	var object_template2 = pushing_scene
	var object2: Node2D = object_template2.instantiate()
	add_child(object2)

func _on_joystick_joystick_input(strength, direction, delta):
	newDir = direction
	input_vector.x = newDir.x
	input_vector.y = newDir.y
	
	was_running = is_running
	is_running = not input_vector.is_zero_approx()
	
	#animacao para correr
	play_run_idle_animation_joystick()
	#girar sprite
	rotate_sprite()

func play_run_idle_animation_joystick() -> void:
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("Idle")

