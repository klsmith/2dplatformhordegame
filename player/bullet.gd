extends RigidBody2D
class_name Bullet

static var SCENE := "res://player/bullet.tscn"

var initial_speed := 0.0
var slowed := false
var sound_finished := false
var particles_finished := false
var has_collided := false
var prev_position := Vector2(position)

static func create(initPosition: Vector2, initVelocity: Vector2) -> Bullet:
	var instance: Bullet = load(SCENE).instantiate()
	instance.position = initPosition
	instance.prev_position = initPosition
	instance.linear_velocity = initVelocity
	instance.initial_speed = initVelocity.length()
	instance.apply_force(initVelocity)
	return instance

@onready var sprite := %BulletSprite as Sprite2D
@onready var smear := %BulletSmearSprite as Sprite2D
@onready var sound := %BulletSoundPlayer as AudioStreamPlayer2D
@onready var particles := %HitParticles as GPUParticles2D
@onready var collision := $CollisionShape2D as CollisionShape2D

func _ready() -> void:
	freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
	sprite.visible = true
	smear.visible = false

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func handle_collision(body: Node2D) -> void:
	if has_collided: return
	has_collided = true
	deal_damage(body)
	sound.play()
	particles.emitting = true
	freeze = true;
	linear_velocity = Vector2.ZERO
	gravity_scale = 0;
	collision.disabled = true

func deal_damage(target: Node2D) -> void:
	@warning_ignore("unsafe_method_access")
	if target.has_method('take_damage'):
		target.take_damage(10)

func _on_area_2d_body_entered(body: Node2D) -> void:
	handle_collision(body)

func _process(delta: float) -> void:
	if (has_collided):
		sprite.visible = false
		smear.visible = false
		if (sound_finished and particles_finished):
			queue_free()
	else:
		sprite.visible = false
		smear.visible = true
	smear.rotation = prev_position.angle_to_point(position)
	smear.scale.x = position.distance_to(prev_position) / 3
	prev_position = Vector2(position)

func _on_bullet_sound_player_finished() -> void:
	sound_finished = true

func _on_hit_particles_finished() -> void:
	particles_finished = true
