extends Area2D
class_name Platform

@export var jump_force = 800

func _on_body_entered(body):
	if body is Player:
		if body.velocity.y > 0:
			body.jump(jump_force)
