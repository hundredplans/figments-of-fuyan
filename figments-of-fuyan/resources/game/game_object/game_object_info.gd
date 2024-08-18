class_name GameObjectInfoGD
extends Resource

@export var id: int
@export var name: String
@export var models: Array[PackedScene]
@export var points: Array[Array]
@export var gdscript: GDScript
@export var data: GDScript

#region Data
func createData() -> GameObjectDataGD:
	var resource := Resource.new()
	resource.script = data
	resource.id = id
	return resource
#endregion
#region Models
func getModel(loaded_data: GameObjectDataGD = createData()) -> GameObjectGD:
	var variation: int = loaded_data.variation
	var packed_scene: PackedScene = models[variation]
	var _model: Node3D = packed_scene.instantiate()
	_model.script = gdscript
	_model.setInfo(self, loaded_data)
	return _model
#endregion
