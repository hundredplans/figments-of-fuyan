class_name TileGD
extends Node3D

signal highlight_obj
signal multi_tile_obj_hovered

@onready var ModelManager: Node3D = $ModelManager
@onready var Effects: Node3D = $Effects

var interactable_tiles: Array
var tile_outlines: Array
var tile_state: Array
var top_of_cliff_wall: Array
@export var collision_points: PackedVector3Array
@onready var types: Array = [tile, obj, wall, tdeco, wdeco]

@export var tile: Dictionary
@export var wdeco: Dictionary
@export var tdeco: Dictionary
@export var obj: Dictionary
@export var wall: Dictionary

@export var solid_status: int = 0
@export var w: int
@export var tpos: Vector3
@export var unit_height: float
@export var fneighbours: Array
@export var id: int

var Unit: UnitGD
var Tiles: TilesGD
var LevelMap: LevelMapGD
var LevelUI: LevelUIGD

func onTTpos(_w: int = w) -> Vector4:
	return Vector4(tpos.x, tpos.y, tpos.z, _w)

func setMaterial(mat: Material, btab: int = -1) -> void:
	match btab:
		-2: for i in range(1, 5): setMaterial(mat, i)
		-1: for i in range(5): setMaterial(mat, i)
		2: 
			if !(wall.model.is_empty()):
				for model in wall.model:
					for mesh in model.meshes:
						mesh.set_surface_override_material(0, mat)
		_:
			if !types[btab].model == null:
				for mesh in types[btab].model.meshes:
					mesh.set_surface_override_material(0, mat)

func setOutline(mat: Material) -> void:
	if !types[0].model == null:
		for mesh in types[0].model.meshes.filter(func(x: MeshInstance3D): return x.get_surface_override_material_count() > 1):
			mesh.set_surface_override_material(1, mat)
	
func getTrueHeight() -> float:
	return 0.3 + (w * 1.2) + (0.6 if tile.type in [1, 2] else 0.0)

func isDeepWater() -> bool: return tile.id == 4
func isWater() -> bool: return tile.id in [3, 4]
func isShallowWater() -> bool: return tile.id == 3

func setObjectHighlight() -> void:
	if LevelMap.verifyLock(LevelMap.HIGHLIGHT_OBJ) and !LevelUI.is_mouse_in_ui:
		var state: bool = mouse_entered_tile or mouse_entered_obj
		if !types[1].model == null:
			highlight_obj.emit(state)
		elif obj.multi_tile.size() > 0 and tile.id > 0: multi_tile_obj_hovered.emit(state)
	
func onSetupObjectHighlight() -> void:
	if !types[1].model == null:
		for body in types[1].model.bodies:
			body.mouse_entered.connect(isMouseInObj.bind(true))
			body.mouse_exited.connect(isMouseInObj.bind(false))

var mouse_entered_obj: bool = false
var mouse_entered_tile: bool = false
func isMouseInObj(x: bool) -> void:
	mouse_entered_obj = x
	setObjectHighlight()

func isMouseInTile(x: bool) -> void:
	mouse_entered_tile = x
	setObjectHighlight()

