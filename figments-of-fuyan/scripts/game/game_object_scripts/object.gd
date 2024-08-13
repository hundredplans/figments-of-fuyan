class_name ObjectGD
extends TileObjectGD

func _ready():
	add_to_group("Objects")
	add_to_group("TileObjects")

func _enter_tree():
	setMapPosition(data.position)

func onCoordsToPosition(coords: Vector4i) -> Vector3:
	return Vector3((sqrt(3) * coords.x + sqrt(3) * coords.y * 0.5), (coords.w * 0.6) + 0.3, coords.y * 3 / 2.0)

func setMapPosition(_position: Vector3) -> void:
	position = _position

func setPosition(coords := Vector4i.ZERO, point := Vector3.ZERO, force_tile_lock: bool = false) -> void:
	if info.lock_tile or force_tile_lock: setMapPosition(onCoordsToPosition(coords))
	else: position = point
	data.position = position
	data.height = coords.w

func getHeight() -> int:
	return data.height
