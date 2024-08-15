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
	if !Engine.is_editor_hint():
		for child in World.get_children() + Lights.get_children(): child.free()
		for data in LevelInfo.data: data.onLoad(World).owner = self
		for light_info in LevelInfo.lights: light_info.onLoad(Lights).owner = self
		
		var packed := PackedScene.new()
		packed.pack(self)
		ResourceSaver.save(packed, scene_file_path)
#endregion
#region Lights
func onLevelInfoChanged(_LevelInfo: LevelInfoGD) -> void:
	if World != null:
		if _LevelInfo == null and LevelInfo != null:
			LevelInfo.lights = Lights.get_children().map(LightInfo.onConvertNode)
			ResourceSaver.save(LevelInfo)
			for child in World.get_children() + Lights.get_children(): child.free()
#endregion
