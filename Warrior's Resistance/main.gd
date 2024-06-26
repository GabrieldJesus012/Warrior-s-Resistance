extends Node

@export var game_ui: CanvasLayer
@export var game_over_ui: PackedScene

func _ready():
	GameManager.game_over.connect(trigger_game_over)

func trigger_game_over():
	#deletar GameUi
	if game_ui: 
		game_ui.queue_free()
		game_ui= null
	
	#criar GameOverUi
	var game_over = game_over_ui.instantiate()
	add_child(game_over)
