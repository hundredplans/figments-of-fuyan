class_name SavedData extends Resource

# Stores the id to the info
@export var id: int
func _init(_id: int = 0) -> void:
	id = _id

static func onLoadModel(data: SavedData, parent: Node3D) -> FofGD:
	var model := FofGD.new()
	var info: FofInfo = Helper.getResourcesRecursiveID(data.getInfoType(), data.id)
	
	model.script = info.gdscript
	model.info = info
	
	parent.add_child(model)
	model.onLoadData(data)
	return model
	
func getInfoType() -> GDScript: return FofInfo
