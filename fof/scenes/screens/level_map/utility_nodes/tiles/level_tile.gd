class_name TileGD
extends Node3D

@onready var Effects: Node3D = $Effects
@export var tile: Node3D
@export var wall: Node3D
@export var obj: Node3D
@export var tdeco: Node3D
@export var wdeco: Node3D

var area: int = 0
@export var info: Dictionary
@export var vision_status: int = 0
@export var solid_status: int = 0
var original_solid_status: int = 0
var tile_state: Array

func on_load_info(type: String) -> void:
	type = type.to_lower()
	match type:
		"tile", "wall": get(type).on_load_info(info[type], area)
		"tdeco", "wdeco", "obj": get(type).on_load_info(info[type])
		
func set_material(mat: Material, btab: int = -1) -> void:
	for type in Helper.BTAB_TO_TYPE[btab]:
		get(type).set_material(mat)

func unit_state() -> String:
	for _unit_state in tile_state:
		if _unit_state in Helper.unit_states:
			return _unit_state
	return ""
	
var HeightDropLabel: Node3D
var hovered_type: Variant = Vector2.ZERO

func on_update_materials(UnitSelected: UnitGD) -> void:
	on_manage_height_drop_label(UnitSelected)
	
func on_manage_height_drop_label(UnitSelected: UnitGD) -> void:
	if hovered_type.x == 4 and hovered_type.z != -1:
		for state in tile_state:
			if state == "PathHovered":
				if HeightDropLabel == null or HeightDropLabel.is_queued_for_deletion():
					HeightDropLabel = preload("res://scenes/screens/level_map/height_drop_label.tscn").instantiate()
					Effects.add_child(HeightDropLabel)
					HeightDropLabel.look_at(\
					Vector3(UnitSelected.global_position.x, UnitSelected.global_position.y + UnitSelected.height.eye, UnitSelected.global_position.z))
					
					if hovered_type.z == 0:
						HeightDropLabel.get_node("Sprite3D").texture = preload("res://scenes/screens/level_map/red_skull.png")
						HeightDropLabel.get_node("Label3D").visible = false
					else: HeightDropLabel.get_node("Label3D").text = str(hovered_type.z)
				return
			
	if HeightDropLabel != null:
		HeightDropLabel.queue_free()
