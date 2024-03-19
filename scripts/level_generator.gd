extends Node2D
@onready var platform_parent = $PlatformParent

var viewport_size
var platform_scene = preload("res://scenes/platform.tscn")

@export var platform_width = 136
@export var y_offset = 65
@export var y_distance_between_platform = 100
@export var level_size = 10
var start_platform_y: int
var generated_platform_count: int

# Called when the node enters the scene tree for the first time.
func _ready():
	viewport_size = get_viewport_rect().size
	start_platform_y = viewport_size.y - (y_distance_between_platform * 2)
	generated_platform_count = 0
	generate_level(start_platform_y, true)

func generate_next_level(player_y_pos):
	var end_of_level_pos = start_platform_y - (generated_platform_count * y_distance_between_platform)
	var threshold = end_of_level_pos + y_distance_between_platform * 8
	if player_y_pos <= threshold:
		generate_level(end_of_level_pos, false)

func create_platform(location: Vector2):
	var platform = platform_scene.instantiate()
	platform.global_position = location
	platform_parent.add_child(platform)
	return platform

func create_ground():
	var platform_count = ceil((viewport_size.x / platform_width))
	
	for i in range(platform_count):
		var ground_location = Vector2(i * platform_width, viewport_size.y - y_offset)
		create_platform(ground_location)

func generate_level(start_y: float, generate_ground: bool):
	if(generate_ground):
		create_ground()
	
	for i in range(level_size):
		var max_x_pos = viewport_size.x - platform_width
		var rand_x = randf_range(0.0, max_x_pos)
		var location: Vector2 
		location.x = rand_x
		location.y = start_y - (y_distance_between_platform * i)
		create_platform(location)
		generated_platform_count += 1
