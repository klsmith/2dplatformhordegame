extends CharacterBody2D

var speed := 50.0

@onready var nav := $NavigationAgent2D as NavigationAgent2D

func _ready() -> void:
	call_deferred("actor_setup")

func actor_setup() -> void:
	await get_tree().physics_frame
	set_target(global_position)

func set_target(new_target: Vector2) -> void:
	nav.target_position = new_target
	
func _physics_process(delta: float) -> void:
	if nav.is_navigation_finished():
		return
	var current_position := global_position
	var next_position := nav.get_next_path_position()
	var dir = current_position.direction_to(next_position)
	rotation = dir.angle() + deg_to_rad(90)
	velocity = dir * speed
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("beetle_control"):
		set_target(get_global_mouse_position())
