class_name SavedDataLevel extends SavedData

func _init(_id: int = 0) -> void:
	super(_id)

func onLoadModel(parent: Node3D) -> LevelGD:
	var model = Node3D.new()
	model.script = getBaseInfo().gdscript
	model.onLoad(self, parent)
	return model

func getBaseInfo() -> LevelInfoGD: return Helper.getResourcesRecursiveID(LevelInfoGD, id)
