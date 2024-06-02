extends Node2D
signal destroy_arrow

@onready var Pivot: Node2D = %Pivot
var to: Vector3
var Camera: Camera3D
const DEATH_DELAY: float = 3
func setInfo(_Camera: Camera3D, _to: Vector3) -> void:
	Camera = _Camera
	to = _to
	onProcessPosition()

func _ready() -> void:
	await get_tree().create_timer(DEATH_DELAY).timeout
	destroy_arrow.emit()
	queue_free()

func _process(_delta: float) -> void:
	onProcessPosition()

func onProcessPosition() -> void:
	var unprojected_pos: Vector2 = Camera.unproject_position(to)
	Pivot.look_at(unprojected_pos)
	position.x = clamp(unprojected_pos.x - 30, 0, 1900)
