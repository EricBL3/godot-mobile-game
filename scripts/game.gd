extends Node2D

@onready var level_generator = $LevelGenerator
@onready var ground_sprite = $GroundSprite

@onready var parallax_1 = $ParallaxBackground/ParallaxLayer
@onready var parallax_2 = $ParallaxBackground/ParallaxLayer2
@onready var parallax_3 = $ParallaxBackground/ParallaxLayer3
@onready var hud = $UILayer/HUD

signal player_died(score, highscore)
signal pause_game

var camera_scene = preload("res://scenes/game_camera.tscn")
var camera: GameCamera = null

var player_scene = preload("res://scenes/player.tscn")
var player: Player = null
var player_spawn_pos: Vector2
@export var player_spawn_pos_y_offset = 135

var viewport_size: Vector2

var score: int
var highscore: int

var save_file_path = "user://highscore.save"

func _ready():
	viewport_size = get_viewport_rect().size
	player_spawn_pos.x = viewport_size.x / 2
	player_spawn_pos.y = viewport_size.y - player_spawn_pos_y_offset
	
	ground_sprite.global_position.x = viewport_size.x / 2
	ground_sprite.global_position.y = viewport_size.y
	
	setup_parallax_layer(parallax_1)
	setup_parallax_layer(parallax_2)
	setup_parallax_layer(parallax_3)
	
	hud.visible = false
	ground_sprite.visible = false
	hud.set_score(0)
	hud.pause_game.connect(_on_hud_pause_game)
	
	load_score()

func get_parallax_sprite_scale(parallax_sprite: Sprite2D):
	var parallax_tex = parallax_sprite.get_texture()
	var parallax_tex_width = parallax_tex.get_width()
	
	var scale = viewport_size.x / parallax_tex_width
	var result = Vector2(scale, scale)
	
	return result
	
func setup_parallax_layer(parallax_layer: ParallaxLayer):
	var sprite = parallax_layer.find_child("Sprite2D")
	if sprite:
		sprite.scale = get_parallax_sprite_scale(sprite)
		var my = sprite.scale.y * sprite.get_texture().get_height()
		parallax_layer.motion_mirroring.y = my 

func _process(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
		
	if player && level_generator:
		var player_y_pos = player.global_position.y
		level_generator.generate_next_level(player_y_pos)
	if player:
		if score < (viewport_size.y - player.global_position.y):
			score = (viewport_size.y - player.global_position.y)
			hud.set_score(score)

func new_game():
	reset_game()
	player = player_scene.instantiate()
	player.global_position = player_spawn_pos
	add_child(player)
	
	camera = camera_scene.instantiate()
	camera.setup_camera(player)
	add_child(camera)
	
	if player:
		level_generator.start_generation()
		player.player_died.connect(_on_player_died)
	
	hud.visible = true
	ground_sprite.visible = true
	score = 0
	

func _on_player_died():
	hud.visible = false
	
	if score > highscore:
		highscore = score
		save_score()
		
	player_died.emit(score, highscore)

func reset_game():
	hud.set_score(0)
	hud.visible = false
	ground_sprite.visible = false
	level_generator.reset_level()
	if player:
		player.queue_free()
		player = null
	
	if camera:
		camera.queue_free()
		camera = null

func save_score():
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	file.store_var(highscore)
	file.close()

func load_score():
	if FileAccess.file_exists(save_file_path):
		var file = FileAccess.open(save_file_path, FileAccess.READ)
		highscore = file.get_var()
		file.close()

func _on_hud_pause_game():
	pause_game.emit()
