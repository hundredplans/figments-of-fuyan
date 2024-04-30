extends Node3D

const NUMBER_SCALE_TIME: float = 0.15
var NUMBER_SHAKE_SPEED: int = 12

var SpectateCamera: Node3D
var type: String = "UnitFieldStatus"
var unit_field_status_materials: Dictionary

@onready var SlotOne: Sprite3D = %SlotOne
@onready var FloatingStats: Node3D = %FloatingStats
@onready var Numbers: Node3D = %Numbers
@onready var Effects: Node3D = %Effects
var is_top: bool

func _process(delta: float) -> void:
	if visible:
		for child in Numbers.get_children() + FloatingStats.get_children() + Effects.get_children():
			child.rotation_degrees.z += NUMBER_SHAKE_SPEED * delta
			
		var child_zero: Node3D = Numbers.get_child(0)
		if child_zero.rotation_degrees.z < -10 or child_zero.rotation_degrees.z > 10: NUMBER_SHAKE_SPEED *= -1
		
		look_at(SpectateCamera.global_position)
		
func onUpdateStat(stat: int, stat_changed: String, color: String) -> void:
	var StatNumber: Node3D = Numbers.get_node(stat_changed)
	
	var ScaleTween := create_tween()
	ScaleTween.tween_property(StatNumber, "scale:y", 0, NUMBER_SCALE_TIME)
	ScaleTween.finished.connect(onUpdateStatBounceBack.bind(stat, stat_changed, color))
	
func onUpdateStatBounceBack(stat: int, stat_changed: String, color: String) -> void:
	var StatNumber: Node3D = Numbers.get_node(stat_changed)
	for child in StatNumber.get_children(): child.queue_free()
	
	onCreateBaseStat(stat, stat_changed, color)
	
	var ScaleTween := create_tween()
	ScaleTween.tween_property(StatNumber, "scale:y", 1, NUMBER_SCALE_TIME)

func setStatNumberMaterial(NewNumber: Node3D, color: String) -> void:
	NewNumber.get_child(0).set_surface_override_material(0, unit_field_status_materials[color][int(is_top)])

func onSetTopMaterial(_is_top: bool) -> void:
	is_top = _is_top
	for child in Numbers.get_children(): setStatNumberMaterial(child.get_child(0), child.color)
	SlotOne.no_depth_test = is_top
	setFloatingStatMaterial()

var BASE_MATERIAL_ON_TOP: BaseMaterial3D = preload("res://assets/materials/unit_field_status_materials/base_material_unshaded_on_top.tres")
var BASE_MATERIAL_UNSHADED: BaseMaterial3D = preload("res://assets/materials/unit_field_status_materials/base_material_unshaded.tres")
var GREY_HEART_UNSHADED: BaseMaterial3D = preload("res://assets/materials/unit_field_status_materials/grey_unshaded.tres")
var GREY_HEART_UNSHADED_ON_TOP: BaseMaterial3D = preload("res://assets/materials/unit_field_status_materials/grey_unshaded_on_top.tres")

var floating_stats_materials: Dictionary = {}
func setFloatingStatMaterial() -> void:
	for child in FloatingStats.get_children():
		if !(child.name == "Health" and grey_heart):
			if is_top:
				child.get_child(0).set_surface_override_material(0, BASE_MATERIAL_ON_TOP)
			else:
				child.get_child(0).set_surface_override_material(0, BASE_MATERIAL_UNSHADED)
		else:
			if is_top:
				child.get_child(0).set_surface_override_material(0, GREY_HEART_UNSHADED_ON_TOP)
			else:
				child.get_child(0).set_surface_override_material(0, GREY_HEART_UNSHADED)

func setUnit(Unit: UnitGD) -> void:
	var path: String = "res://scenes/screens/level_ui/unit_status/unit_status_pieces/zzz.png" if\
	Unit.team == 0 else "res://scenes/screens/level_ui/unit_status/unit_status_pieces/in_range.png"
	SlotOne.texture = load(path)
	
	for child in FloatingStats.get_children():
		floating_stats_materials[child] = BASE_MATERIAL_UNSHADED
	
	onCreateBaseStat(Unit.attack, "Attack")
	onCreateBaseStat(Unit.health, "Health")
	onCreateBaseStat(Unit.speed, "Speed")
	 
	for fx in Unit.unit_fx:
		onAddUnitFX(fx[0], fx[1])
	
func onCreateBaseStat(val: int, stat_changed: String, color: String = "BASE") -> void:
	var NewNumber: Node3D = load("res://scenes/screens/level_map/floating_stats/numbers/" + Helper.NUM_TO_STRING_NUM[val] + ".glb").instantiate()
	var StatNumber: Node3D = Numbers.get_node(stat_changed)
	StatNumber.add_child(NewNumber)
	StatNumber.color = color
	setStatNumberMaterial(NewNumber, color)
	StatNumber.on_sort_children()

var grey_heart: bool = false
func onAddUnitFX(fx_type: String, _charges: int = -1) -> void:
	match fx_type:
		"Armor":
			grey_heart = true
			setFloatingStatMaterial()
