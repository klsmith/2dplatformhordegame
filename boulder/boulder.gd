extends RigidBody2D


func _ready() -> void:
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	contact_monitor = true;
	max_contacts_reported = 5;
