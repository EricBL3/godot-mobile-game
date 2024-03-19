extends Node2D

@onready var level_generator = $LevelGenerator
@onready var ground_sprite = $GroundSprite

@onready var parallax_1 = $ParallaxBackground/ParallaxLayer
@onready var parallax_2 = $ParallaxBackground/ParallaxLayer2
@onready var parallax_3 = $ParallaxBackground/ParallaxLayer3



var camera_scene = preload("res://scenes/game_camera.tscn")
var camera: GameCamera = null

var player_scene = preload("res://scenes/player.tscn")
var player: Player = null
var player_spawn_pos: Vector2
@export var player_spawn_pos_y_offset = 135

var viewport_size: Vector2

func _ready():
	viewport_size = get_viewport_rect().size
	player_spawn_pos.x = viewport_size.x / 2
	player_spawn_pos.y = viewport_size.y - player_spawn_pos_y_offset
	
	ground_sprite.global_position.x = viewport_size.x / 2
	ground_sprite.global_position.y = viewport_size.y
	
	setup_parallax_layer(parallax_1)
	setup_parallax_layer(parallax_2)
	setup_parallax_layer(parallax_3)
	
	new_game()

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


func new_game():
	player = player_scene.instantiate()
	player.global_position = player_spawn_pos
	add_child(player)
	
	camera = camera_scene.instantiate()
	camera.setup_camera(player)
	add_child(camera)
