class_name GameOverUi
extends CanvasLayer

@onready var time_label: Label = %TimeLabel
@onready var monsters_label: Label = %MonstersLabel

@export var restart_delay: float = 5.0
var restart_cooldown: float

func _ready():
	time_label.text = GameManager.time_elapsed_string
	monsters_label.text = str(GameManager.monsters_count)
	restart_cooldown= restart_delay

func _process(delta):
	restart_cooldown -= delta
	if restart_cooldown <= 0.0:
		restart_game()

func restart_game():
	GameManager.resert()
	get_tree().reload_current_scene()

