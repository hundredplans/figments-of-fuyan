@tool
extends Node

#region Exports
@export var UnitInfo: UnitInfoGD:
	set(_UnitInfo):
		onUnitChanged(_UnitInfo)
		UnitInfo = _UnitInfo
#endregion

#region Globals
@onready var World: Node3D = $World
@onready var ColShapeHolder: Node3D = $PlaceCollisionShapeHere
#endregion

func _ready() -> void:
	if !Engine.is_editor_hint() and UnitInfo != null:
		for child in World.get_children() + ColShapeHolder.get_children(): child.free()
		var model: UnitGD = UnitInfo.getBaseData().onLoadModel(World)
		model.setOwner(self)
		model.position = Vector3.ZERO
		
		if model.info.collision_shape != null:
			var col_shape: CollisionShape3D = model.info.collision_shape.instantiate()
			ColShapeHolder.add_child(col_shape)
			col_shape.owner = self
		
		var packed_scene := PackedScene.new()
		packed_scene.pack(self)
		ResourceSaver.save(packed_scene, scene_file_path)

func onUnitChanged(_UnitInfo: UnitInfoGD) -> void:
	if _UnitInfo == null and UnitInfo != null and ColShapeHolder.get_child_count() > 0:
		var col_shape: CollisionShape3D = ColShapeHolder.get_child(0)
		var packed_scene := PackedScene.new()
		packed_scene.pack(col_shape)
		UnitInfo.collision_shape = packed_scene
		ResourceSaver.save(UnitInfo)
		for child in World.get_children() + ColShapeHolder.get_children(): child.free()
