extends Node2D

@export var speed := 200.0
@export var segments : Array[CreatureSegment] = []

@onready var Link := preload("res://creature/constraint_link_2d.gd")
@onready var Shape := preload("res://addons/2d_shapes/shapes/Ellipse.gd")
@onready var body_container := $BodyContainer as Node

var head : ConstraintLink2D = null

func _ready() -> void:
	# handle the body
	var last_body_part : Node2D = null
	if segments.size() > 1:
		var body : Array[CreatureSegment]= segments.slice(1, segments.size())
		body.reverse()
		for segment in body:
			var part := realize(segment, last_body_part)
			body_container.add_child(part)
			last_body_part = part
	# handle the head
	if segments.size() > 0:
		head = realize(segments[0], last_body_part)
		add_child(head)
	pass

func realize(segment: CreatureSegment, target: Node2D) -> ConstraintLink2D:
	var link := Link.new()
	link.target = target
	link.target_distance = segment.distance
	link.add_child(make_shape(segment))
	return link

func make_shape(segment: CreatureSegment) -> Ellipse:
	var shape := Shape.new()
	shape.size = Vector2(segment.size, segment.size)
	shape.style = 2 #Filled + Outline
	shape.fill_color = Color.BLACK
	shape.outline_color = Color.WHITE
	shape.outline_width = 3
	return shape

func _physics_process(delta: float) -> void:
	var mouse := get_global_mouse_position()
	var vel := global_position.direction_to(mouse) * (speed * delta)
	var dis := global_position.distance_to(mouse)
	if (dis > vel.length()):
		position = position + vel
	else:
		position = mouse
	head.resolve_constraints()
