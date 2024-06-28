extends Node

signal game_over
signal play_push_animation

var player: Player
var player_position: Vector2
var is_game_over: bool = false

var time_elapsed: float= 0.0
var time_elapsed_string: String
var meat_count: int = 0
var monsters_count: int = 0
var p_on: bool = false #se o push está ligado


func _process(delta:float):
	time_elapsed +=delta
	#floor arredonda para baixo
	#round arredonda ou para baixo ou para cima
	#ceil arredonda para cima
	var time_elapsed_in_second: int = floori(time_elapsed)
	var second: int = time_elapsed_in_second % 60
	var minutes: int = time_elapsed_in_second /60
	
	# - % formatar algo - d digito - 02 2 digitos e : da hora ex: 03:20 
	
	time_elapsed_string = "%02d:%02d"  % [minutes, second]

func end_game():
	if is_game_over: return
	is_game_over = true
	game_over.emit()

func resert():
	player = null
	player_position= Vector2.ZERO
	is_game_over = false
	time_elapsed = 0.0
	time_elapsed_string = "00:00"
	meat_count = 0
	monsters_count = 0
	for connection in game_over.get_connections():
		game_over.disconnect(connection.callable)


