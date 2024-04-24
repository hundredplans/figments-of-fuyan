extends Node

var SpectateCamera: Node3D
var LevelMap: LevelMapGD
var Tiles: TilesGD
@export var LevelUI: LevelUIGD

var units: Dictionary = {} # Dict of UnitGD: [UnitStatus, UnitFieldStatus, UnitStatus]
func onUnitAwakened(Unit: UnitGD) -> void:
	var UnitFieldStatus: Node3D = preload("res://scenes/screens/level_ui/unit_status/unit_field_status/unit_field_status.tscn").instantiate()
	units[Unit] = [UnitFieldStatus]
	Unit.add_child(UnitFieldStatus)
	UnitFieldStatus.position.y = Unit.height.stat
	UnitFieldStatus.SpectateCamera = SpectateCamera
	UnitFieldStatus.unit_field_status_materials = unit_field_status_materials
	UnitFieldStatus.onSetUnit(Unit)
	onAddUnitStatus(Unit, "UnitStatusRegular")

const speeds: Dictionary = {
	"TurnUsed": 0.02,
	"TurnUnused": 0.12,
	"TurnActive": 0.2,}
	
const modulates: Dictionary = {
	"TurnUsed": Color("8fbf8f"),
	"TurnUnused": Color("43bf43"),
	"TurnActive": Color("00bf00"),
}

const COLOR_INFO: Dictionary = {
	"BASE": Color(1, 1, 1),
	"RED": Color(1, 0, 0),
	"GREEN": Color(0, 1, 0)
}

func onAddUnitStatus(Unit: UnitGD, type: String = "UnitStatusRegular") -> void:
	var UnitStatus: Control = preload("res://scenes/screens/level_ui/unit_status/unit_status.tscn").instantiate()
	UnitStatus.type = type
	units[Unit].append(UnitStatus)
	
	match type:
		"UnitStatusRegular": LevelUI.Statuses.add_child(UnitStatus)
		"UnitStatusExtra": pass
	UnitStatus.onSetUnit(Unit)
	UnitStatus.ArtPop.pressed.connect(LevelUI.onSpectateEnemyOrAlly.bind(Unit))
	UnitStatus.SelectedMask.mouse_entered.connect(onUnitInspected.bind(Unit))
	UnitStatus.SelectedMask.mouse_exited.connect(onUnitUninspected.bind(Unit))
	
	UnitStatus.ShiftingBackground.material.set_shader_parameter\
	("modulate", modulates["TurnUnused"] if Unit.team == 0 else Color("c11e00")) 
	if Unit.team == 1: 
		UnitStatus.ShiftingBackground.material.set_shader_parameter("speed", 0.02)

func onFindRegularUnitStatus(Unit: UnitGD) -> Array:
	var arr: Array = []
	for UnitStatus in units[Unit]: 
		if UnitStatus.type.begins_with("UnitStatus"):
			arr.append(UnitStatus)
	return arr

func onSetUnitStatusTurnStatus(Unit: UnitGD, status: int) -> void:
	pass

func onSetUnitStatusExtra(Unit: UnitGD, state: bool) -> void:
	pass

func onDeathBegin(Unit: UnitGD, delay: float) -> void:
	for UnitStatus in onFindRegularUnitStatus(Unit):
		var ScaleTween: Tween = create_tween()
		ScaleTween.tween_property(self, "scale", Vector2.ZERO, delay * 2)
		UnitStatus.on_rotate_queue_free = true

func onDeathFinished(Unit: UnitGD) -> void:
	for UnitStatus in onFindRegularUnitStatus(Unit):
		UnitStatus.queue_free()
	units.erase(Unit)

func onUpdateStats(Unit: UnitGD, stat_changed: String, color: String) -> void:
	for UnitStatus in units[Unit]:
		UnitStatus.onUpdateStat(Unit.get(stat_changed), stat_changed, COLOR_INFO[color])

func onUnitSpectated(Unit: UnitGD, state: bool) -> void:
	for UnitStatus in onFindRegularUnitStatus(Unit):
		UnitStatus.Rainbow.visible = state
		UnitStatus.onSetLightMask(state)
	
func onUpdateEnemyVision(Unit: UnitGD, state: bool) -> void:
	pass
	
func onStartPhaseStart() -> void: # Sets everyone to turn unused
	pass
	
func onPlayerPhaseStart() -> void: # Sets allies to turn unused
	pass
	
func onPlayerEndPhaseStart() -> void: # Sets allies to turn used
	pass
	
func onAIPhaseStart() -> void: # Sets AI to turn unused
	pass
	
func onAIEndPhaseStart() -> void: # Sets AI to turn used
	pass
	
func setFieldStatusVisible(state: bool) -> void:
	pass

func onEnemyInRange(Unit: UnitGD, state: bool) -> void: # Changes slot one
	pass

func onUnitInspected(Unit: UnitGD) -> void:
	if LevelMap.action_lock in ["", "HandRegular"] and !LevelUI.is_status_box_moving:
		Tiles.on_set_tile_material(Unit.Tile, "UnitInspected")
	
func onUnitUninspected(Unit: UnitGD) -> void:
	if LevelMap.action_lock in ["", "HandRegular"] and !LevelUI.is_status_box_moving:
		Tiles.on_remove_tile_material(Unit.Tile)
	
var unit_field_status_materials: Dictionary = {
	"BASE": [], # [bot, top_level]
	"RED": [],
	"GREEN": [],
}

func onCreateUnitFieldStatusMaterials():
	for key in unit_field_status_materials:
		var color: Color = get(key)
		var bot_material: ShaderMaterial = preload("res://scenes/screens/level_map/floating_stats/color_materials/floating_number_material.tres").duplicate() 
		bot_material.set_shader_parameter("albedo", color)
		unit_field_status_materials[key].append(bot_material)
		
		var top_material: ShaderMaterial = preload("res://scenes/screens/level_map/floating_stats/color_materials/floating_number_material_no_depth.tres").duplicate() 
		top_material.set_shader_parameter("albedo", color)
		unit_field_status_materials[key].append(top_material)
