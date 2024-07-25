class_name StatusManagerGD
extends Node

var SpectateCamera: SpectateCameraGD
var LevelMap: LevelMapGD
var Tiles: TilesGD
var Vision: VisionGD
var Units: UnitsGD
var LevelUI: LevelUIGD

var units: Dictionary = {} # Dict of UnitGD: [UnitStatus, UnitFieldStatus, UnitStatus]

func _ready() -> void:
	onCreateUnitFieldStatusMaterials()
	onStoreAllInfoFX()

func onUnitAwakened(Unit: UnitGD) -> void:
	var UnitFieldStatus: Node3D = preload("res://scenes/screens/level_map/utility_nodes/status_manager/unit_status/unit_field_status/unit_field_status.tscn").instantiate()
	units[Unit] = [UnitFieldStatus]
	UnitFieldStatus.SpectateCamera = SpectateCamera
	Unit.add_child(UnitFieldStatus)
	UnitFieldStatus.visible = Unit.Tile in Vision.getTeamVision()
	UnitFieldStatus.position.y = Unit.height.stat
	UnitFieldStatus.unit_field_status_materials = unit_field_status_materials
	UnitFieldStatus.setUnit(Unit)
	onAddUnitStatus(Unit, "UnitStatusRegular")

const speeds: Dictionary = {
	UnitGD.TURN_INACTIVE: 0.02,
	UnitGD.TURN_USED: 0.02,
	UnitGD.TURN_UNUSED: 0.12,
	UnitGD.TURN_ACTIVE: 0.2,}
	
const modulates: Dictionary = {
	UnitGD.TURN_INACTIVE: Color("8fbf8f"),
	UnitGD.TURN_USED: Color("8fbf8f"),
	UnitGD.TURN_UNUSED: Color("43bf43"),
	UnitGD.TURN_ACTIVE: Color("00bf00"),
}

func onAddUnitStatus(Unit: UnitGD, type: String = "UnitStatusRegular") -> void:
	var UnitStatus: Control = preload("res://scenes/screens/level_map/utility_nodes/status_manager/unit_status/unit_status.tscn").instantiate()
	UnitStatus.type = type
	units[Unit].append(UnitStatus)
	UnitStatus.speeds = speeds
	UnitStatus.modulates = modulates
	UnitStatus.COLOR_INFO = COLOR_INFO
	
	match type:
		"UnitStatusRegular": 
			LevelUI.Statuses.add_child(UnitStatus)
			UnitStatus.setUnit(Unit)
		"UnitStatusExtra": 
			LevelUI.UnitStatusState.get_node("Control").add_child(UnitStatus)
			LevelUI.UnitStatusState.get_node("Control/DefaultStatus").visible = false
			UnitStatus.setUnit(Unit)
		"TileHoveredUnitStatus":
			LevelUI.TileHoveredGameCard.add_child(UnitStatus)
			UnitStatus.setUnit(Unit)
			
	UnitStatus.highlight_unit.connect(onHighlightUnit)
	UnitStatus.onEquipTool(Unit.Tool)
	UnitStatus.mouse_in_ui.connect(LevelUI.on_is_mouse_in_ui)
	UnitStatus.ArtPop.pressed.connect(LevelUI.onSpectateEnemyOrAlly.bind(Unit))
	
	for child in [UnitStatus.ArtPop, UnitStatus.SelectedMask]:
		child.mouse_entered.connect(onUnitInspected.bind(Unit))
		child.mouse_exited.connect(onUnitUninspected.bind(Unit))
	
	UnitStatus.ShiftingBackground.material.set_shader_parameter\
	("modulate", modulates[UnitGD.TURN_UNUSED] if Unit.team == 0 else Color("c11e00")) 
	if Unit.team == 1: 
		UnitStatus.ShiftingBackground.material.set_shader_parameter("speed", 0.02)
	
	for stat_info in Units.next_turn_stats: onCreateStatNextTurn(UnitStatus, stat_info)
	
func onFindUnitStatus(Unit: UnitGD, type: String = "UnitStatus") -> Array:
	if units.has(Unit):
		if !Unit.is_dead:
			var arr: Array = []
			for UnitStatus in units[Unit]:
				if UnitStatus.type.begins_with(type):
					arr.append(UnitStatus)
			return arr
	else: print_debug("Missing unit dependency in status manager")
	return []
	
func onEquipTool(Unit: UnitGD) -> void:
	for UnitStatus in onFindUnitStatus(Unit):
		UnitStatus.onEquipTool(Unit.Tool)
	
func setUnitStatusTurnStatus(Unit: UnitGD, status: int) -> void:
	for UnitStatus in onFindUnitStatus(Unit, "Unit"):
		if Unit.team == 0:
			UnitStatus.SlotOne.visible = status == UnitGD.TURN_USED
			if UnitStatus.type.begins_with("UnitStatus"):
				UnitStatus.setUnitStatusState(status)
	
	Unit.turn_status = status

func setUnitStatusExtra(Unit: UnitGD, state: bool) -> void:
	if !state:
		LevelUI.UnitStatusState.get_node("Control/DefaultStatus").visible = true
		for UnitStatus in onFindUnitStatus(Unit, "UnitStatusExtra"):
			UnitStatus.queue_free()
			units[Unit].erase(UnitStatus)
	else: onAddUnitStatus(Unit, "UnitStatusExtra")

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
	for UnitStatus in onFindUnitStatus(Unit, "Unit"):
		UnitStatus.onUpdateStat(Unit.get(stat_changed.to_lower()), stat_changed, color)

func onUnitSpectated(Unit: UnitGD, state: bool) -> void:
	for UnitStatus in onFindUnitStatus(Unit, "UnitStatusRegular"):
		UnitStatus.Rainbow.visible = state
		UnitStatus.setLightMask(state)
		
	for UnitStatus in onFindUnitStatus(Unit, "UnitFieldStatus"):
		UnitStatus.onSetTopMaterial(state)
	
	setUnitStatusExtra(Unit, state)
	
func setAllRegularUnitStatus(team: int, state: int) -> void:
	for Unit in units.keys().filter(func(x: UnitGD): return x.team == team and x.turn_status != state):
		setUnitStatusTurnStatus(Unit, state)
	
func onStartPhaseStart() -> void: # Sets everyone to turn unused
	setAllRegularUnitStatus(0, UnitGD.TURN_INACTIVE)
	setAllRegularUnitStatus(1, UnitGD.TURN_INACTIVE)

func onHandPhaseStart() -> void: # Sets allies to turn unused
	setAllRegularUnitStatus(0, UnitGD.TURN_UNUSED)
	
func onPlayerEndTurnPhaseStart() -> void:
	setAllRegularUnitStatus(0, UnitGD.TURN_INACTIVE)
	
func onAIPhaseStart() -> void:
	setAllRegularUnitStatus(1, UnitGD.TURN_UNUSED)
	
func onAIEndTurnPhaseStart() -> void:
	setAllRegularUnitStatus(0, UnitGD.TURN_INACTIVE)
	
func setUnitStatusVisible(Unit: UnitGD, state: bool) -> void:
	for UnitStatus in onFindUnitStatus(Unit, "Unit"): UnitStatus.visible = state

func onEnemyInRange(Unit: UnitGD, state: bool) -> void: # Changes slot one
	for UnitStatus in onFindUnitStatus(Unit, "Unit"):
		UnitStatus.SlotOne.visible = state

func onUnitInspected(Unit: UnitGD) -> void:
	if LevelMap.verifyLock(LevelMap.INSPECT_UNIT) and !LevelUI.is_status_box_moving:
		Tiles.on_set_tile_material(Unit.Tile, "UnitInspected")
	
func onUnitUninspected(Unit: UnitGD) -> void:
	if LevelMap.verifyLock(LevelMap.INSPECT_UNIT) and !LevelUI.is_status_box_moving:
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

#func onUpdateEnemyVision(Unit: UnitGD, state: bool) -> void:
	#for UnitStatus in onFindUnitStatus(Unit, "Unit"):
		#UnitStatus.visible = state
		#
	#if Unit.team == 1: # Eventually implement as a specific type of base_fx that checks whether the applier is in vision
		#for _Unit in Units.on_units(TeamRelationGD.new(1)):
			#for UnitStatus in onFindUnitStatus(_Unit):
				#for base_fx in UnitStatus.UnitFX.get_children():
					#if base_fx.info_fx.fx_type == "CocusPocus":
						#base_fx.visible = base_fx.info_fx.Unit.Tile in Vision.getTeamVision()
#region StatusFX
var all_status_info_fx: Array
func onStoreAllInfoFX() -> void:
	const DIR_PATH: String = "res://scenes/screens/level_map/utility_nodes/status_manager/unit_status/status_fx/infos/"
	all_status_info_fx = Array(DirAccess.get_files_at(DIR_PATH)).map(func(x: String): return load(DIR_PATH + x))
	
func onFindStatusInfo(id: int) -> StatusFXInfoGD:
	return all_status_info_fx.filter(func(x: StatusFXInfoGD): return x.id == id)[0]

func onCreateStatusFX(Unit: UnitGD, id: int, AppliedBy := AppliedByGD.new()) -> StatusFXGD:
	var status_info: StatusFXInfoGD = onFindStatusInfo(id)
	var status_fx := Node.new()
	status_fx.script = status_info.status_fx_script
	status_fx.setInfo(Unit, status_info, AppliedBy)
	add_child(status_fx)
	
	Unit.onAddStatusFX(status_fx)
	for UnitStatus in onFindUnitStatus(Unit, "UnitFieldStatus"): UnitStatus.onCreateStatusFX(status_fx)
	for UnitStatus in onFindUnitStatus(Unit): UnitStatus.onCreateStatusFX(status_fx)
	return status_fx
	
func onRemoveStatusFX(status_fx: StatusFXGD) -> void:
	if status_fx != null:
		for UnitStatus in onFindUnitStatus(status_fx.Unit, "Unit"): UnitStatus.onRemoveStatusFX(status_fx)
		
		status_fx.get_parent().remove_child(status_fx)
		status_fx.queue_free()
		status_fx.Unit.status_fx_array.erase(status_fx)
	
func onRefreshUnitStatus(Unit: UnitGD) -> void:
	for UnitStatus in onFindUnitStatus(Unit, "Unit"): UnitStatus.onRefresh()
#endregion

func onHighlightUnit(status_fx: StatusFXGD) -> void:
	var Unit: UnitGD = status_fx.HighlightUnit
	if Unit != null and Unit.Tile in Vision.getTeamVision():
		LevelUI.onSpectateEnemyOrAlly(Unit)

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

func getHealNextTurnColorValue(value: int) -> String:
	var color_value: int = clamp(value, -3, 3)
	return BUFF_COLORS[color_value * (clamp(value, -1, 1))]

func onCreateBuffNextTurn(stat_info: StatInfoGD) -> void:
	if stat_info.stat_type != StatsGD.HEALTH:
		for UnitStatus in onFindUnitStatus(stat_info.Unit):
			onCreateStatNextTurn(UnitStatus, stat_info)
		
		for UnitStatus in onFindUnitStatus(stat_info.Unit, "UnitFieldStatus"):
			UnitStatus.onCreateBuffNextTurn(stat_info.getStatName(), stat_info.value * -1)
	else: onCreateHealNextTurn(stat_info)
	
func onRemoveBuffNextTurn(stat_info: StatInfoGD) -> void:
	if stat_info.stat_type != StatsGD.HEALTH:
		for UnitStatus in onFindUnitStatus(stat_info.Unit):
			UnitStatus.onRemoveBuffNextTurn(stat_info.getStatName())

		for UnitStatus in onFindUnitStatus(stat_info.Unit, "UnitFieldStatus"):
			UnitStatus.onRemoveBuffNextTurn(stat_info.getStatName())
	else: onRemoveHealNextTurn(stat_info)

func onCreateHealNextTurn(stat_info: StatInfoGD) -> void:
	for UnitStatus in onFindUnitStatus(stat_info.Unit):
		UnitStatus.onCreateHealNextTurn(getHealNextTurnColorValue(stat_info.value))
	
	for UnitStatus in onFindUnitStatus(stat_info.Unit, "UnitFieldStatus"):
		UnitStatus.onCreateHealNextTurn(stat_info.value)
	
func onRemoveHealNextTurn(stat_info: StatInfoGD) -> void:
	for UnitStatus in onFindUnitStatus(stat_info.Unit):
		UnitStatus.onRemoveHealNextTurn()

	for UnitStatus in onFindUnitStatus(stat_info.Unit, "UnitFieldStatus"):
		UnitStatus.onRemoveHealNextTurn()

func onUnequipTool(Unit: UnitGD) -> void:
	for UnitStatus in onFindUnitStatus(Unit):
		UnitStatus.onUnequipTool()

func onRefreshNextTurnStats(stats: Array) -> void:
	for stat_info in stats:
		onRemoveBuffNextTurn(stat_info)
		onCreateBuffNextTurn(stat_info)
		
func onCreateStatNextTurn(UnitStatus: UnitStatusGD, stat_info: StatInfoGD) -> void:
	UnitStatus.onCreateBuffNextTurn(stat_info.getStatName(), stat_info.value * -1, getBuffColorValue(stat_info.value * -1))

func onToolAbilityUsed(Unit: UnitGD, delay: float) -> void:
	for UnitStatus in onFindUnitStatus(Unit):
		UnitStatus.onToolAbilityUsed(delay)
		
