class_name SavedDataSpawn extends SavedDataObject

@export var spawn_id: int

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _coords := Vector4i.ZERO, _tile_rotation: int = 0,\
	_vision_datastore := VisionDatastore.new(), _variation: int = 0, _rotation: float = 0, _position := Vector3.ZERO,\
	_height: int = 0, _occupied_coords: Array = [], _groups: Array = [], _spawn_id: int = 0) -> void:
	super(_id, _first_init, _public_id, _coords, _tile_rotation, _vision_datastore, _variation, _rotation, _position, _height, _occupied_coords, _groups)
	spawn_id = _spawn_id
	
	for i in range(groups.size()):
		var group: Variant = groups[i]
		if group is String:
			if group == "A": groups[i] = 1
			elif group == "B": groups[i] = 2
			elif group == "C": groups[i] = 3
			elif group == "D": groups[i] = 4
			elif group == "E": groups[i] = 5
			
