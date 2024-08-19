extends Node2D
class_name ConstraintLink2D

@export var target : ConstraintLink2D
@export var target_distance := 1.0


func resolve_constraints() -> void:
	if not target: return
	var dir = global_position.direction_to(target.global_position)
	var scaled_relative_position = dir * target_distance
	target.global_position = global_position + scaled_relative_position
	target.resolve_constraints()
