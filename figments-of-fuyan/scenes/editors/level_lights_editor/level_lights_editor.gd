@tool
extends Node3D

#region Exports
@export var LevelInfo: LevelInfoGD:
	set(_LevelInfo):
		LevelInfo = _LevelInfo
		onLevelInfoChanged()
#endregion
#region Globals
@onready var World: Node3D = $World
@onready var Lights: Node3D = $Lights
#endregion
	
#region Base Functions
func _ready() -> void:
	pass
	
func _on_tree_exited():
	pass
#endregion

#region Setting Level Info
func onLevelInfoChanged() -> void:
	if World != null:
		for child in World.get_children(): child.queue_free()
		if LevelInfo != null:
			for data in LevelInfo.data:
				var loaded = load(data.resource_path)
				loaded.onLoad(World)
#endregion
