class_name VisibleToUnitTile extends VisibleToUnit

var by_objects: Dictionary # The objects that are visible which make this visible
@export var object_public_ids: Array
@export var by_unit: bool # Visible because a Unit is sitting on this tile
#@export var by_adjacency: bool # Visible because this unit is adjacent or on this tile

func onSave() -> void:
	object_public_ids = by_objects.keys().map(func(x: ObjectGD): return x.public_id)
	
func onLoad() -> void:
	for Obj in object_public_ids.map(func(x: int): return Game.onFindPublicIDObject(x)):
		by_objects[Obj] = null
	
func isVisibleToUnit() -> bool:
	return direct or by_unit or !by_objects.keys().is_empty()

func setByUnit(state: bool) -> void:
	by_unit = state
	
func onAddObject(Obj: ObjectGD) -> void:
	by_objects[Obj] = null
	
func onRemoveObject(Obj: ObjectGD) -> void:
	by_objects.erase(Obj)
