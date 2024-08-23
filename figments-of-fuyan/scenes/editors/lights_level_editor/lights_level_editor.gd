@tool
extends Node3D

#region Exports
@export var LevelInfo: LevelInfoGD:
	set(_LevelInfo):
		onLevelInfoChanged(_LevelInfo)
		LevelInfo = _LevelInfo
#endregion
#region Globals
@onready var World: Node3D = $World
@onready var Lights: Node3D = $Lights
#endregion
#region Base
func _ready() -> void:
	if !Engine.is_editor_hint() and LevelInfo != null:
		Lights = get_node_or_null("Lights")
		for child in World.get_children() + Lights.get_children(): child.free()
		for data in LevelInfo.data:
			var model: Node3D = data.onLoad(World)
			model.setOwner(self)
		
		for packed in LevelInfo.lights:
			var light: Light3D = packed.instantiate()
			Lights.add_child(light)
			light.owner = self
			
		var packed_scene := PackedScene.new()
		packed_scene.pack(self)
		ResourceSaver.save(packed_scene, scene_file_path)
		
#endregion
#region Lights
func onLevelInfoChanged(_LevelInfo: LevelInfoGD) -> void:
	if _LevelInfo == null and LevelInfo != null:
		var lights_array: Array[PackedScene] = []
		for light in Lights.get_children():
			var packed_scene := PackedScene.new()
			packed_scene.pack(light)
			lights_array.append(packed_scene)
			
		LevelInfo.lights = lights_array
		ResourceSaver.save(LevelInfo)
		
		for child in World.get_children() + Lights.get_children(): child.free()
#endregion
