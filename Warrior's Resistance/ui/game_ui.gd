extends CanvasLayer

@onready var time_label = %TimeLabel
@onready var Meet_label = %MeetLabel
@onready var Kills_label = %KillsLabel
@onready var panel_push: Panel = $panel_push

func _process(delta:float):
	time_label.text = GameManager.time_elapsed_string
	Meet_label.text = str(GameManager.meat_count)
	Kills_label.text = str(GameManager.monsters_count)

func _ready():
	update_panel_push_color(false)  

func update_panel_push_color(is_available: bool) -> void:
	if is_available:
		panel_push.modulate = Color(1, 1, 1)  
	else:
		panel_push.modulate = Color(0.52, 0, 0)  
