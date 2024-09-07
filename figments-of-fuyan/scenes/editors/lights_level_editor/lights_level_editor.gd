@tool
extends Node3D

#region Exports
@export var level_info: LevelInfo:
	set(_level_info):
		onLevelInfoChanged(_level_info)
		level_info = _level_info
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
		for data in level_info.data:
			SavedData.onLoadModel(data, World).setOwner(self)
		
		for packed in level_info.lights:
			var light: Light3D = packed.instantiate()
			Lights.add_child(light)
			light.owner = self
			
		var packed_scene := PackedScene.new()
		packed_scene.pack(self)
		ResourceSaver.save(packed_scene, scene_file_path)
		
#endregion
#region Lights
func onLevelInfoChanged(_level_info: LevelInfo) -> void:
	if _level_info == null and level_info != null:
		var lights_array: Array[PackedScene] = []
		for light in Lights.get_children():
			var packed_scene := PackedScene.new()
			packed_scene.pack(light)
			lights_array.append(packed_scene)
			
		level_info.lights = lights_array
		ResourceSaver.save(LevelInfo)
		
		for child in World.get_children() + Lights.get_children(): child.free()
#endregion
