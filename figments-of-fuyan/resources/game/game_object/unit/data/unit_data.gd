class_name UnitDataGD
extends GameObjectDataGD

const INFO_PATH: String = "res://resources/game/game_object/unit/info/"
@export var team: int
@export var coords: Vector4i

func onLoad(parent: Node3D = null, info: UnitInfoGD = Helper.getResourcesRecursiveID(INFO_PATH, UnitInfoGD, id)) -> UnitGD:
	var model: UnitGD = info.getModel(self)
	model.setRotation(rotation)
	model.setMapPosition()
	parent.add_child(model)
	return model
