class_name GameObjectInfoGD
extends Resource

@export var id: int
@export var name: String
@export var gdscript: GDScript

@export_group("3D")
@export var models: Array[PackedScene]
@export var points: Array[Array]
@export_group("")

func getModel(variation: int) -> PackedScene:
	return models[variation]
