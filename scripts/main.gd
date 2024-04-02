extends Node
@onready var screens = $Screens
@onready var game = $Game

func _ready():
	screens.start_game.connect(_on_screens_start_game)
	screens.delete_level.connect(_on_screens_delete_level)
	game.player_died.connect(_on_player_died)
	
func _on_screens_start_game():
	game.new_game()

func _on_player_died(score, highscore):
	await(get_tree().create_timer(0.75).timeout)
	screens.game_over(score, highscore)

func _on_screens_delete_level():
	game.reset_game()
