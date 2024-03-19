extends CharacterBody2D
class_name Player

@onready var animator = $AnimationPlayer

@export var speed = 300
@export var accelerometer_speed = 130
@export var stop_offset = 15
@export var teleport_margin = 20
@export var gravity = 15
@export var max_fall_velocity = 1000

var screen_size

var use_accelerometer = false

func _ready():
	screen_size = get_viewport_rect().size
	if OS.get_name() == "Android" || OS.get_name() == "iOS":
		use_accelerometer = true

func _process(delta):
	if velocity.y > 0:
		if animator.current_animation != "fall":
			animator.play("fall")
	elif velocity.y < 0:
		if animator.current_animation != "jump":
			animator.play("jump")

func _physics_process(delta):
	
	velocity.y += gravity
	if velocity.y > max_fall_velocity:
		velocity.y = max_fall_velocity
	
	if use_accelerometer:
		velocity.x = Input.get_accelerometer().x * accelerometer_speed
	else:
		var dir = Input.get_axis("move_left", "move_right")
		if dir:
			velocity.x = dir * speed
		else:
			# Useful for making the character slide and then stop.
			# Change the value of stop_offset to make it stop moving slower or faster.
			velocity.x = move_toward(velocity.x, 0, speed / stop_offset)
	
	move_and_slide()
	
	if global_position.x > screen_size.x + teleport_margin:
		global_position.x = -teleport_margin
	if global_position.x < -teleport_margin:
		global_position.x = screen_size.x + teleport_margin

func jump(jump_force):
	velocity.y = -jump_force
