extends Control

@onready var top_bar_bg = $TopBarBG
@onready var top_bar = $TopBar
@onready var score_label = $TopBar/ScoreLabel

@export var margin = 10

func _ready():
	var os_name = OS.get_name()
	
	if os_name == "Android" || os_name == "iOS":
		var safe_area = DisplayServer.get_display_safe_area()
		var safe_area_top = safe_area.position.y
		
		var screen_scale = DisplayServer.screen_get_scale()
		safe_area_top = (safe_area_top / screen_scale)
		
		top_bar.position.y += safe_area_top
		top_bar_bg.size.y += safe_area_top + margin
		
		
		
		MyUtility.add_log_message("Safe area: " + str(safe_area))
		MyUtility.add_log_message("Window size: " + str(DisplayServer.window_get_size()))
		MyUtility.add_log_message("Safe area top: " + str(safe_area_top))
		MyUtility.add_log_message("top bar pos: " + str(top_bar.position))

func _on_pause_btn_pressed():
	pass # Replace with function body.

func set_score(score: int):
	score_label.text = "Score: " + str(score)
