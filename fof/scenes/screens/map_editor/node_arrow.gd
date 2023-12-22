extends Line2D

signal destroy_arrow
@onready var Area: Area2D = $Area2D
@onready var ColShape: CollisionShape2D = $Area2D/CollisionShape2D
var from := Vector2.ZERO
var to := Vector2.ZERO
var can_press: bool = false

func _ready() -> void: ColShape.shape = RectangleShape2D.new()

func on_create_arrow(_from: Vector2i, _to: Vector2i, Nodes: Control) -> void:
	from = _from
	to = _to
	clear_points()
	if from != Vector2.ZERO:
		var NodeButton: Control = Nodes.get_child(to.x).get_child(to.y)
		var TargetButton: Control = Nodes.get_child(from.x).get_child(from.y)
		call_deferred("add_point", NodeButton.global_position + (NodeButton.size / 2))
		call_deferred("add_point", TargetButton.global_position + (TargetButton.size / 2))
		
		var distance: float = NodeButton.global_position.distance_to(TargetButton.global_position)
		Area.position = TargetButton.global_position
		ColShape.shape.size.x = distance
		
		if from.x > to.x:
			Area.rotation_degrees = rad_to_deg(asin((TargetButton.global_position.y - NodeButton.global_position.y) /distance))
			Area.position.x -= 130
		elif from.x < to.x:
			Area.rotation_degrees = rad_to_deg(acos((TargetButton.global_position.x - NodeButton.global_position.x) / distance))
			Area.position.x += 175
		else: 
			Area.rotation_degrees = 90
			Area.position.x += 25

func _process(_delta: float) -> void: if can_press and Input.is_action_just_pressed("LeftClick"): destroy_arrow.emit(self)
func _on_area_2d_mouse_entered(): can_press = true
func _on_area_2d_mouse_exited(): can_press = false
