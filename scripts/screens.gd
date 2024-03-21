extends CanvasLayer
@onready var console = $Debug/ConsoleLog
@onready var title_screen = $TitleScreen
@onready var pause_screen = $PauseScreen
@onready var game_over_screen = $GameOverScreen

var current_screen = null

func _ready():
	console.visible = false
	register_buttons()
	change_screen(title_screen)


func _on_toggle_console_pressed():
	console.visible = !console.visible


func register_buttons():
	var buttons = get_tree().get_nodes_in_group("buttons")
	if buttons.size() > 0:
		for button in buttons:
			if button is ScreenButton:
				button.clicked.connect(_on_button_pressed)

func _on_button_pressed(button):
	match button.name:
		"TitlePlay":
			print("Play")
			change_screen(null)
		"PauseRetry":
			print("Pause retry")
			change_screen(null)
		"PauseBack":
			print("Pause back")
			change_screen(title_screen)
		"PauseClose":
			print("Pause close")
			change_screen(null)
		"GameOverRetry":
			print("Game over retry")
			change_screen(null)
		"GameOverBack":
			print("Game over back")
			change_screen(title_screen)

func change_screen(new_screen):
	if current_screen:
		var disappear_tween = current_screen.disappear()
		await(disappear_tween.finished)
		current_screen.visible = false
	current_screen = new_screen
	if current_screen:
		var appear_tween = current_screen.appear()
		await(appear_tween.finished)
		get_tree().call_group("buttons", "set_disabled", false)
