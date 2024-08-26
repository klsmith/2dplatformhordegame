extends RigidBody2D
class_name Flare

static var SCENE := "res://flare/flare.tscn"

var marked_for_destroy := false
var pickup_target : Node2D = null

static func create(initPosition: Vector2, initVelocity: Vector2) -> Flare:
	var instance: Flare = load(SCENE).instantiate()
	instance.position = initPosition
	instance.linear_velocity = initVelocity
	instance.rotation = initVelocity.angle()
	instance.apply_force(initVelocity)
	return instance

@onready var light := $PointLight2D as Light2D
@onready var sprite := $Sprite2D as Sprite2D

func _ready() -> void:
	FlareManager.register(self)
	var flicker := get_tree().create_tween().bind_node(self).set_loops()
	flicker.tween_property(light, "texture_scale", 0.95, 0.5)
	flicker.tween_property(light, "texture_scale", 1, 0.5)
	var slow_fade := get_tree().create_tween()
	slow_fade.tween_property(light, "energy", 0, 60)
	slow_fade.tween_callback(start_destroy)

func start_destroy() -> void:
	if not marked_for_destroy:
		marked_for_destroy = true
		var fade_out := get_tree().create_tween()
		fade_out.tween_property(light, "texture_scale", 0, 0.5)
		fade_out.parallel()
		fade_out.tween_property(sprite, "scale", Vector2.ZERO, 0.5)
		if pickup_target != null:
			fade_out.parallel()
			fade_out.tween_property(self, "global_position", pickup_target.global_position, 0.5)
		fade_out.parallel()
		fade_out.tween_property($CollisionShape2D, "scale", Vector2.ZERO, 0.5)
		fade_out.tween_callback(queue_free)

func _exit_tree() -> void:
	FlareManager.deregister(self)

func pickup(target: Node2D) -> void:
	pickup_target = target
	start_destroy()
