extends CanvasLayer

@onready var time_label = %TimeLabel
@onready var Meet_label = %MeetLabel
@onready var Kills_label = %KillsLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _process(delta:float):
	time_label.text = GameManager.time_elapsed_string
	Meet_label.text = str(GameManager.meat_count)
	Kills_label.text = str(GameManager.monsters_count)

func _ready():
	GameManager.connect("play_push_animation", Callable(self, "play_panel_push_animation"))

func play_panel_push_animation():
	animation_player.play("panel_push")
