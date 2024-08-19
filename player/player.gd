extends CharacterBody2D
class_name Player

const SPEED := 300.0
const JUMP_VELOCITY := -400.0
const camera_target_cap := 128.0
const camera_target_sense := 0.5

@export var camera: Camera2D

var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as float
var shoot_dir := Vector2.ZERO
var shoot_pos := Vector2.ZERO
var shooting := false
var can_shoot := true
var reloading := false
var mag_size := 25
var mag_curr := mag_size
var ammo_size := 500
var ammo_curr := ammo_size

@onready var camera_target := %CameraTarget as RemoteTransform2D
@onready var gun_pivot := %GunPivot as Node2D
@onready var viewport := get_viewport() as Viewport
@onready var shoot_cooldown := %ShootCooldown as Timer
@onready var gun_sound := %GunSoundPlayer as AudioStreamPlayer2D
@onready var dry_fire_sound := %DryFireSound as AudioStreamPlayer2D
@onready var reload_sound := %ReloadSound as AudioStreamPlayer2D
@onready var reload_progress := %ReloadProgress as TextureProgressBar

signal current_mag_changed(new_mag_curr: int)
signal current_ammo_changed(new_ammo_curr: int)

func _ready() -> void:
	camera_target.remote_path = camera.get_path()
	reload_progress.value = 0
	reload_progress.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"):
		get_tree().quit()
	if event.is_action("ui_fullscreen"):
		var m = DisplayServer.window_get_mode()
		if m == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if event.is_action_pressed("player_flashlight"):
		throw_flare()
	if event.is_action_pressed("player_shoot"):
		shooting = true
	if event.is_action_released("player_shoot"):
		shooting = false
	if event.is_action_pressed("player_reload"):
		reload()

func throw_flare() -> void:
	var vel := shoot_dir * 1000
	var flare := Flare.create(position, vel)
	get_tree().root.add_child(flare)
	pass

var flashlight_mode = 3
@onready var flashlight_ambient := %FlashLightAmbient as Light2D
@onready var flashlight_direct := %FlashLightDirect as Light2D
func toggle_flashlight() -> void:
	flashlight_mode = wrapi(flashlight_mode + 1, 0, 4)
	flashlight_ambient.visible = bool(flashlight_mode & 1)
	flashlight_direct.visible = bool(flashlight_mode & 2)

func _process(delta: float) -> void:
	flashlight_direct.visible = tilemap_col == 0
	if reloading:
		reload_progress.visible = true
		reload_progress.value = reload_sound.get_playback_position() * 100
	else:
		reload_progress.visible = false
		reload_progress.value = 0
	gun_pivot.look_at(get_global_mouse_position());
	var viewMousePosition := viewport.get_mouse_position()
	var viewCenter := viewport.get_visible_rect().size / 2
	var dis := clamp(
		viewCenter.distance_to(viewMousePosition) * camera_target_sense,
		0, camera_target_cap
	) as float
	camera_target.position = Vector2.RIGHT.rotated(gun_pivot.rotation) * dis
	shoot_dir = Vector2.RIGHT.rotated(gun_pivot.rotation)
	shoot_pos = (shoot_dir * 32)
	handle_shooting()
	queue_redraw()

func _on_shoot_cooldown_timeout() -> void:
	can_shoot = true

func handle_shooting() -> void:
	if shooting and can_shoot and !reloading:
		if has_mag():
			shoot()
		elif has_ammo():
			reload()
		else:
			dry_fire()

func has_mag() -> bool:
	return mag_curr > 0

func has_ammo() -> bool:
	return ammo_curr > 0

@onready var muzzle_flash := %MuzzleFlashAnimation as AnimationPlayer

func shoot() -> void:
	gun_sound.play()
	muzzle_flash.play("muzzle_flash")
	var vel := shoot_dir * 5000
	var bullet := Bullet.create(position + shoot_pos, vel)
	get_tree().root.add_child(bullet)
	mag_curr -= 1
	emit_signal("current_mag_changed", mag_curr)
	can_shoot = false
	shoot_cooldown.start()

func reload() -> void:
	var missing := mag_size - mag_curr
	if missing <= 0 or ammo_curr == 0: 
		return
	reloading = true
	var take = mini(missing, ammo_curr)
	ammo_curr -= take
	mag_curr += take
	reload_sound.play()
	emit_signal("current_mag_changed", mag_curr)
	emit_signal("current_ammo_changed", ammo_curr)

func dry_fire() -> void:
	dry_fire_sound.play()
	can_shoot = false
	shoot_cooldown.start()

func _on_reload_sound_finished() -> void:
	reloading = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("player_left", "player_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()

func _draw() -> void:
	if get_tree().debug_collisions_hint:
		draw_arc(Vector2.ZERO, camera_target_cap, 0, TAU + 1, 64, Color.WHITE)
		draw_circle(camera_target.position, 2, Color.BLUE)
		draw_circle(shoot_pos, 2, Color.GREEN)

var tilemap_col = 0

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	tilemap_col += 1

func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	tilemap_col -= 1
