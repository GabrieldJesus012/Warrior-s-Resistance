extends CanvasLayer

@onready var time_label = %TimeLabel
@onready var Meet_label = %MeetLabel
@onready var Kills_label = %KillsLabel

func _process(delta:float):
	time_label.text = GameManager.time_elapsed_string
	Meet_label.text = str(GameManager.meat_count)
	Kills_label.text = str(GameManager.monsters_count)
