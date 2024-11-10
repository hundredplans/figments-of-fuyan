class_name SavedDataGameObject extends SavedData

@export var tile_rotation: int
@export var vision_datastore: VisionDatastore
@export var coords: Vector4i

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _coords := Vector4.ZERO, _tile_rotation: int = 0, _vision_datastore := VisionDatastore.new()) -> void:
	super(_id, _first_init, _public_id)
	coords = _coords
	tile_rotation = _tile_rotation
	vision_datastore = _vision_datastore

func getInfoType() -> GDScript: return GameObjectInfo
