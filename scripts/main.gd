extends Node
@onready var screens = $Screens
@onready var game = $Game

var game_in_progress = false

func _ready():
	screens.start_game.connect(_on_screens_start_game)
	screens.delete_level.connect(_on_screens_delete_level)
	game.player_died.connect(_on_player_died)
	game.pause_game.connect(_on_game_pause_game)
	
	DisplayServer.window_set_window_event_callback(_on_window_event)
	
func _on_screens_start_game():
	game_in_progress = true
	game.new_game()

func _on_player_died(score, highscore):
	game_in_progress = false
	await(get_tree().create_timer(0.75).timeout)
	screens.game_over(score, highscore)

func _on_screens_delete_level():
	game_in_progress = false
	game.reset_game()

func _on_game_pause_game():
	get_tree().paused = true
	screens.pause_game()

func _on_window_event(event):
	match event:
		DisplayServer.WINDOW_EVENT_FOCUS_OUT:
			if game_in_progress:
				_on_game_pause_game()
		DisplayServer.WINDOW_EVENT_CLOSE_REQUEST:
			get_tree().quit()
