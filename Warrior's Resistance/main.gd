extends Node

@export var game_ui: CanvasLayer
@export var game_over_ui: PackedScene
@export var pushing_scene: PackedScene

func _ready():
	GameManager.game_over.connect(trigger_game_over)

func _input(event: InputEvent) -> void:
		if Input.is_action_pressed("play_push"):
			if GameManager.p_on == false:
				pushing()
				GameManager.p_on = true

func trigger_game_over():
	#deletar GameUi
	if game_ui: 
		game_ui.queue_free()
		game_ui= null
	
	#criar GameOverUi
	var game_over = game_over_ui.instantiate()
	add_child(game_over)

func pushing():
	var object_template2 = pushing_scene
	var object2: Node2D = object_template2.instantiate()
	object2.position = GameManager.player_position
	add_child(object2)
