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
@onready var BuffNextTurn: Node3D = $BuffNextTurn

var is_top: bool

func _process(_delta: float) -> void:
	if visible: look_at(SpectateCamera.global_position)
		
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

	for child in BuffNextTurn.get_children():
		for grandchild in child.get_children():
			grandchild.get_child(0).set_surface_override_material(0,\
			load("res://scenes/screens/level_map/utility_nodes/vfx/next_turn_buffs/buff_materials/buff_material_"\
			+ buff_colors[child.name] + ("top" if is_top else "") + ".tres"))

func setUnit(Unit: UnitGD) -> void:
	var path: String = "res://scenes/screens/level_ui/unit_status/unit_status_pieces/zzz.png" if\
	Unit.team == 0 else "res://scenes/screens/level_ui/unit_status/unit_status_pieces/in_range.png"
	SlotOne.texture = load(path)
	
	for child in FloatingStats.get_children():
		floating_stats_materials[child] = BASE_MATERIAL_UNSHADED
	
	onCreateBaseStat(Unit.attack, "Attack")
	onCreateBaseStat(Unit.health, "Health")
	onCreateBaseStat(Unit.speed, "Speed")
	 
	for fx in Unit.unit_fx: onAddUnitFX(fx)
	
func onCreateBaseStat(val: int, stat_changed: String, color: String = "BASE") -> void:
	var StatNumber: Node3D = Numbers.get_node(stat_changed)
	StatNumber.color = color
	for num in str(val):
		var NewNumber: Node3D = load("res://scenes/screens/level_map/floating_stats/numbers/" + Helper.NUM_TO_STRING_NUM[int(num)] + ".glb").instantiate()
		StatNumber.add_child(NewNumber)
		setStatNumberMaterial(NewNumber, color)
	StatNumber.on_sort_children()

var grey_heart: bool = false
func onAddUnitFX(info_fx: InfoFXGD) -> void:
	match info_fx.fx_type:
		"Armor":
			grey_heart = true
			setFloatingStatMaterial()

var buff_colors: Dictionary = {
	"Attack": "",
	"Health": "",
	"Speed": "",
	"Heal": "",
}

func onCreateBuffNextTurn(stat: String, value: int) -> void:
	stat = stat.capitalize()
	var prefix: String = "down" if value < 0 else "up"
	var arrow_value: int = 0
	match abs(value):
		1: arrow_value = 1
		2, 3: arrow_value = 2
		_: arrow_value = 3
		
	var color_value: int = 0
	match abs(value):
		1, 2, 4: color_value = 1
		3, 5: color_value = 2
		_: color_value = 3
		
	buff_colors[stat.capitalize()] = prefix + str(color_value)
	if BuffNextTurn.get_node(stat.capitalize()).get_child_count() > 0:
		for child in BuffNextTurn.get_node(stat.capitalize()).get_children(): child.queue_free()
	var Arrow: Node3D = load("res://scenes/screens/level_map/utility_nodes/vfx/next_turn_buffs/" + prefix + str(arrow_value) + ".glb").instantiate()
	BuffNextTurn.get_node(stat.capitalize()).add_child(Arrow)
	setFloatingStatMaterial()
	if stat == "Health": onSortHealth()

func onRemoveBuffNextTurn(stat: String) -> void:
	stat = stat.capitalize()
	BuffNextTurn.get_node(stat).get_child(0).queue_free()
	if stat == "Health": onSortHealth()

func onCreateHealNextTurn(heal: int) -> void:
	var color_value: int = 0
	match abs(heal):
		1, 2, 4: color_value = 1
		3, 5: color_value = 2
		_: color_value = 3
		
	buff_colors["Heal"] = "up" + str(color_value)
	if BuffNextTurn.get_node("Heal").get_child_count() > 0:
		for child in BuffNextTurn.get_node("Heal").get_children(): child.queue_free()
		
	var Arrow: Node3D = preload("res://scenes/screens/level_map/utility_nodes/vfx/next_turn_buffs/up_heal.glb").instantiate()
	BuffNextTurn.get_node("Heal").add_child(Arrow)
	setFloatingStatMaterial()
	onSortHealth()
	
func onRemoveHealNextTurn() -> void:
	for child in BuffNextTurn.get_node("Heal").get_children(): child.queue_free()
	onSortHealth()

func onSortHealth() -> void:
	var HealNode: Node3D = BuffNextTurn.get_node("Heal")
	var HealthNode: Node3D = BuffNextTurn.get_node("Health")
	var amount: int = HealNode.get_children().filter(isValid).size() + HealthNode.get_children().filter(isValid).size()
	match amount:
		1: HealNode.position.x = 0; HealthNode.position.x = 0
		2: HealNode.position.x = -0.1; HealthNode.position.x = 0.1

func _ready() -> void: $AnimationPlayer.play("Animation")
func isValid(x: Node) -> bool: return !x.is_queued_for_deletion()
