extends CanvasLayer

@onready var time_label = %TimeLabel
@onready var Meet_label = %MeetLabel

func _process(delta:float):
	time_label.text = GameManager.time_elapsed_string
	Meet_label.text = str(GameManager.meat_count)
