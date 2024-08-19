extends AnimatableBody2D


const MAX_HEALTH := 50.0;
var health := MAX_HEALTH;

@onready var hit_flash_player := %HitFlashPlayer as AnimationPlayer
@onready var skeleton_player := %SkeletonPlayer as AnimationPlayer

func _ready() -> void:
	skeleton_player.play('IDLE');

func take_damage(damage: float) -> void:
	health -= damage;
	hit_flash_player.stop();
	hit_flash_player.play('HIT_FLASH');
	if health <= 0:
		queue_free();
