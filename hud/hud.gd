extends CanvasLayer

const FPS_LABEL_FORMAT := "FPS: %s"
const MAG_LABEL_FORMAT := "Mag: %s / %s"
const AMMO_LABEL_FORMAT := "Ammo: %s / %s"

@export var player : Player;

@onready var fps_label := %FpsLabel as Label
@onready var mag_label := %MagLabel as Label
@onready var ammo_label := %AmmoLabel as Label

func _ready() -> void:
	player.current_mag_changed.connect(on_player_current_mag_changed)
	player.current_ammo_changed.connect(on_player_current_ammo_changed)
	set_mag_label()
	set_ammo_label()
	
func _process(delta: float) -> void:
	fps_label.text = FPS_LABEL_FORMAT % [Engine.get_frames_per_second()]
	
func on_player_current_mag_changed(mag_curr: int) -> void:
	set_mag_label()

func set_mag_label() -> void:
	mag_label.text = MAG_LABEL_FORMAT % [player.mag_curr, player.mag_size]

func on_player_current_ammo_changed(amm_curr: int) -> void:
	set_ammo_label()

func set_ammo_label() -> void:
	ammo_label.text = AMMO_LABEL_FORMAT % [player.ammo_curr, player.ammo_size]
