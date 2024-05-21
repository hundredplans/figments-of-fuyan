extends Node

var SpectateCamera: Node3D
var LevelMap: LevelMapGD
var Tiles: TilesGD
var Vision: VisionGD
var Units: UnitsGD
@export var LevelUI: LevelUIGD

var units: Dictionary = {} # Dict of UnitGD: [UnitStatus, UnitFieldStatus, UnitStatus]

func _ready() -> void:
	onCreateUnitFieldStatusMaterials()
	onStoreAllInfoFX()

func onUnitAwakened(Unit: UnitGD) -> void:
	var UnitFieldStatus: Node3D = preload("res://scenes/screens/level_ui/unit_status/unit_field_status/unit_field_status.tscn").instantiate()
	units[Unit] = [UnitFieldStatus]
	UnitFieldStatus.SpectateCamera = SpectateCamera
	Unit.add_child(UnitFieldStatus)
	UnitFieldStatus.position.y = Unit.height.stat
	UnitFieldStatus.unit_field_status_materials = unit_field_status_materials
	UnitFieldStatus.setUnit(Unit)
	onAddUnitStatus(Unit, "UnitStatusRegular")

const speeds: Dictionary = {
	"TurnInactive": 0.02,
	"TurnUsed": 0.02,
	"TurnUnused": 0.12,
	"TurnActive": 0.2,}
	
const modulates: Dictionary = {
	"TurnInactive": Color("8fbf8f"),
	"TurnUsed": Color("8fbf8f"),
	"TurnUnused": Color("43bf43"),
	"TurnActive": Color("00bf00"),
}

func onAddUnitStatus(Unit: UnitGD, type: String = "UnitStatusRegular") -> void:
	var UnitStatus: Control = preload("res://scenes/screens/level_ui/unit_status/unit_status.tscn").instantiate()
	UnitStatus.type = type
	units[Unit].append(UnitStatus)
	UnitStatus.speeds = speeds
	UnitStatus.modulates = modulates
	UnitStatus.COLOR_INFO = COLOR_INFO
	
	match type:
		"UnitStatusRegular": 
			LevelUI.Statuses.add_child(UnitStatus)
			UnitStatus.setUnit(Unit)
			UnitStatus.target_ability_pressed.connect(LevelUI.onTargetAbilityBtnPressed)
		"UnitStatusExtra": 
			LevelUI.UnitStatusState.add_child(UnitStatus)
			UnitStatus.setUnit(Unit)
			UnitStatus.setUnitStatusState("TurnActive")
		"TileHoveredUnitStatus":
			LevelUI.TileHoveredGameCard.add_child(UnitStatus)
			UnitStatus.setUnit(Unit)
	
	UnitStatus.ArtPop.pressed.connect(LevelUI.onSpectateEnemyOrAlly.bind(Unit))
	
	UnitStatus.ArtPop.mouse_entered.connect(onUnitInspected.bind(Unit))
	UnitStatus.ArtPop.mouse_exited.connect(onUnitUninspected.bind(Unit))
	
	UnitStatus.SelectedMask.mouse_entered.connect(onUnitInspected.bind(Unit))
	UnitStatus.SelectedMask.mouse_exited.connect(onUnitUninspected.bind(Unit))
	
	UnitStatus.ShiftingBackground.material.set_shader_parameter\
	("modulate", modulates["TurnUnused"] if Unit.team == 0 else Color("c11e00")) 
	if Unit.team == 1: 
		UnitStatus.ShiftingBackground.material.set_shader_parameter("speed", 0.02)
	
func onFindUnitStatus(Unit: UnitGD, type: String = "UnitStatus") -> Array:
	if !Unit.is_dead:
		var arr: Array = []
		for UnitStatus in units[Unit]:
			if UnitStatus.type.begins_with(type):
				arr.append(UnitStatus)
		return arr
	return []

func setUnitStatusTurnStatus(Unit: UnitGD, status: String) -> void:
	var unit_statuses: Array = units[Unit].duplicate()
	for UnitStatus in unit_statuses:
		if Unit.team == 0:
			setUnitStatusExtra(Unit, Unit.turn_status, status)
			UnitStatus.SlotOne.visible = status == "TurnUsed"
			if UnitStatus.type.begins_with("UnitStatus"):
				UnitStatus.setUnitStatusState(status)
	Unit.turn_status = status
	onUpdateUnitTargetAbilities(Unit)

func setUnitStatusExtra(Unit: UnitGD, old_status: String, status: String) -> void:
	var was_active: bool = old_status == "TurnActive"
	var is_active: bool = status == "TurnActive"
	if !was_active and is_active: onAddUnitStatus(Unit, "UnitStatusExtra")
	elif was_active and !is_active:
		for UnitStatus in onFindUnitStatus(Unit, "UnitStatusExtra"):
			UnitStatus.queue_free()
			units[Unit].erase(UnitStatus)

func onDeathBegin(Unit: UnitGD, delay: float) -> void:
	for UnitStatus in onFindUnitStatus(Unit):
		var ScaleTween: Tween = create_tween()
		ScaleTween.tween_property(UnitStatus, "scale", Vector2.ZERO, delay * 2)
		UnitStatus.on_rotate_queue_free = true

func onDeathFinished(Unit: UnitGD) -> void:
	for UnitStatus in onFindUnitStatus(Unit):
		UnitStatus.queue_free()
	units.erase(Unit)

func onUpdateStats(Unit: UnitGD, stat_changed: String, color: String) -> void:
	for UnitStatus in units[Unit]:
		UnitStatus.onUpdateStat(Unit.get(stat_changed.to_lower()), stat_changed, color)

func onUnitSpectated(Unit: UnitGD, state: bool) -> void:
	for UnitStatus in onFindUnitStatus(Unit, "UnitStatusRegular"):
		UnitStatus.Rainbow.visible = state
		UnitStatus.setLightMask(state)
		
	for UnitStatus in onFindUnitStatus(Unit, "UnitFieldStatus"):
		UnitStatus.onSetTopMaterial(state)
		
func onUpdateEnemyVision(Unit: UnitGD, state: bool) -> void:
	for UnitStatus in units[Unit]: UnitStatus.visible = state
	
func setAllRegularUnitStatus(team: int, state: String) -> void:
	for Unit in units.keys():
		if Unit.team == team: setUnitStatusTurnStatus(Unit, state)
	
func onStartPhaseStart() -> void: # Sets everyone to turn unused
	setAllRegularUnitStatus(0, "TurnInactive")
	setAllRegularUnitStatus(1, "TurnInactive")

func onHandPhaseStart() -> void: # Sets allies to turn unused
	setAllRegularUnitStatus(0, "TurnUnused")
	
func onPlayerEndTurnPhaseStart() -> void: # Sets allies to turn used
	setAllRegularUnitStatus(0, "TurnInactive")
	
func onAIPhaseStart() -> void: # Sets AI to turn unused
	setAllRegularUnitStatus(1, "TurnUnused")
	
func onAIEndTurnPhaseStart() -> void: # Sets AI to turn used
	setAllRegularUnitStatus(0, "TurnInactive")
	
func setUnitStatusVisible(Unit: UnitGD, state: bool) -> void:
	for UnitStatus in units[Unit]: UnitStatus.visible = state

func onEnemyInRange(Unit: UnitGD, state: bool) -> void: # Changes slot one
	for UnitStatus in units[Unit]:
		UnitStatus.SlotOne.visible = state

func onUnitInspected(Unit: UnitGD) -> void:
	if LevelMap.action_lock in ["", "HandRegular"] and !LevelUI.is_status_box_moving:
		Tiles.on_set_tile_material(Unit.Tile, "UnitInspected")
	
func onUnitUninspected(Unit: UnitGD) -> void:
	if LevelMap.action_lock in ["", "HandRegular"] and !LevelUI.is_status_box_moving:
		Tiles.on_remove_tile_material(Unit.Tile, "UnitInspected")
	
var unit_field_status_materials: Dictionary = {
	"BASE": [], # [bot, top_level]
	"RED": [],
	"GREEN": [],
}

const COLOR_INFO: Dictionary = {
	"BASE": Color(1, 1, 1),
	"RED": Color(1, 0, 0),
	"GREEN": Color(0, 1, 0)
}

func onCreateUnitFieldStatusMaterials():
	for key in unit_field_status_materials:
		var color: Color = COLOR_INFO[key]
		var bot_material: ShaderMaterial = preload("res://scenes/screens/level_map/floating_stats/color_materials/floating_number_material.tres").duplicate() 
		bot_material.set_shader_parameter("albedo", color)
		unit_field_status_materials[key].append(bot_material)
		
		var top_material: ShaderMaterial = preload("res://scenes/screens/level_map/floating_stats/color_materials/floating_number_material_no_depth.tres").duplicate() 
		top_material.set_shader_parameter("albedo", color)
		unit_field_status_materials[key].append(top_material)

func onRemoveTileHoveredUnitStatus(Unit: UnitGD) -> void:
	for UnitStatus in onFindUnitStatus(Unit, "TileHoveredUnitStatus"):
		units[Unit].erase(UnitStatus)

func onCreateTileHoveredUnitStatus(Unit: UnitGD) -> void:
	onAddUnitStatus(Unit, "TileHoveredUnitStatus")
	
func onUpdateTargetAbility(Unit: UnitGD, ability: TargetAbilityGD) -> void:
	for UnitStatus in onFindUnitStatus(Unit):
		UnitStatus.onUpdateAbility(ability)

var all_info_fx: Dictionary
func onStoreAllInfoFX() -> void:
	const DIR_PATH: String = "res://scenes/screens/level_ui/unit_status/unit_fx/info_fx/"
	for file_path in DirAccess.get_files_at(DIR_PATH):
		var info_fx := load(DIR_PATH + file_path)
		all_info_fx[info_fx.fx_type] = DIR_PATH + file_path

func onAddUnitFX(Unit: UnitGD, type: String, AppliedBy := AppliedByGD.new()) -> void:
	var info_fx := load(all_info_fx[type])
	info_fx.Unit = AppliedBy.Applier
	for UnitStatus in onFindUnitStatus(Unit):
		var base_fx: Control = UnitStatus.onAddUnitFX(info_fx)
		base_fx.hover_unit_pressed.connect(LevelUI.onSpectateEnemyOrAlly)
	
func onAddAbilityActiveFX(Unit: UnitGD, type: String, AppliedBy := AppliedByGD.new()) -> void:
	if all_info_fx.has(type):
		onAddUnitFX(Unit, type)
	
func onRemoveAbilityActiveFX(Unit: UnitGD, type: String) -> void:
	if all_info_fx.has(type):
		onRemoveUnitFX(Unit, type)
	
func onRemoveUnitFX(Unit: UnitGD, type: String, AppliedBy := AppliedByGD.new()) -> void:
	for UnitStatus in onFindUnitStatus(Unit):
		UnitStatus.onRemoveUnitFX(type, AppliedBy)

func onUpdateUnitTargetAbilities(Unit: UnitGD) -> void:
	for ability in Unit.abilities:
		if ability is TargetAbilityGD:
			onUpdateTargetAbility(Unit, ability)

const BUFF_COLORS: Dictionary = {
	-3: "a90002",
	-2: "fe0002",
	-1: "ff7a69",
	1: "aeffa6",
	2: "11ff00",
	3: "0fc800",
}

func getBuffColorValue(value: int) -> String:
	var color_value: int = 0
	match abs(value):
		1, 2, 4: color_value = 1
		3, 5: color_value = 2
		_: color_value = 3
	return BUFF_COLORS[color_value * (clamp(value, -1, 1))]

func onCreateBuffNextTurn(buff_info_array: BuffInfoArrayGD) -> void:
	for UnitStatus in onFindUnitStatus(buff_info_array.Unit):
		UnitStatus.onCreateBuffNextTurn(buff_info_array.stat, buff_info_array.value, getBuffColorValue(buff_info_array.value))
	
	for UnitStatus in onFindUnitStatus(buff_info_array.Unit, "UnitFieldStatus"):
		UnitStatus.onCreateBuffNextTurn(buff_info_array.stat, buff_info_array.value)
	
func onRemoveBuffNextTurn(buff_info_array: BuffInfoArrayGD) -> void:
	for UnitStatus in onFindUnitStatus(buff_info_array.Unit):
		UnitStatus.onRemoveBuffNextTurn(buff_info_array.stat)

	for UnitStatus in onFindUnitStatus(buff_info_array.Unit, "UnitFieldStatus"):
		UnitStatus.onRemoveBuffNextTurn(buff_info_array.stat)

func onCreateHealNextTurn(heal_info_array: HealInfoArrayGD) -> void:
	for UnitStatus in onFindUnitStatus(heal_info_array.Healee):
		UnitStatus.onCreateHealNextTurn(getBuffColorValue(heal_info_array.heal))
	
	for UnitStatus in onFindUnitStatus(heal_info_array.Healee, "UnitFieldStatus"):
		UnitStatus.onCreateHealNextTurn(heal_info_array.heal)
	
func onRemoveHealNextTurn(heal_info_array: HealInfoArrayGD) -> void:
	for UnitStatus in onFindUnitStatus(heal_info_array.Healee):
		UnitStatus.onRemoveHealNextTurn()

	for UnitStatus in onFindUnitStatus(heal_info_array.Healee, "UnitFieldStatus"):
		UnitStatus.onRemoveHealNextTurn()
