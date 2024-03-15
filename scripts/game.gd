extends Node2D

@onready var player = $Player


var camera_scene = preload("res://scenes/game_camera.tscn")
var camera = null

func _ready():
	camera = camera_scene.instantiate()
	camera.setup_camera(player)
	add_child(camera)
