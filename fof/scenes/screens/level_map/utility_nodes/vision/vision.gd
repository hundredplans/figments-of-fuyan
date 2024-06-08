class_name VisionGD
extends Node3D

@onready var MouseRayCast: RayCast3D = $MouseRayCast

var SpectateCamera: Node3D
var LevelUI: LevelUIGD
var Units: UnitsGD
var Tiles: TilesGD
var GameState: Node
var PlayerManager: PlayerManagerGD
const VISION_RANGE: int = 5

var spawn_tiles: Array = []
func onStartPhaseStart() -> void:
	spawn_tiles = Tiles.on_is_type_get_tiles("Spawn", "obj")
	onApplyGreyscale()
func getTeamVision(team_relation: TeamRelationGD = TeamRelationGD.new(0, "Ally")) -> Array:
	var _vis_tiles: Array = []
	if team_relation.onTeam() == 0:
		_vis_tiles.append_array(spawn_tiles)
		_vis_tiles.append_array(Units.on_units().map(func(x: UnitGD): return x.Tile))
	var vis_tiles: Array = []
	for Unit in Units.on_units(team_relation):
		_vis_tiles.append_array(Unit.visible_tiles)
	for Tile in _vis_tiles:
		if Tile not in vis_tiles:
			vis_tiles.append(Tile)
	return vis_tiles
func onRecalculateVision(Unit: UnitGD, apply_greyscale: bool = true) -> void:
	onRecalculateVisionPrecalculated(Unit, Unit.onCalculateVisionInfo(), apply_greyscale)
func onRecalculateVisionPrecalculated(Unit: UnitGD, vision_info: Dictionary, apply_greyscale: bool = true) -> void:
	match vision_mode:
		0:
			var old_ally_vision: Array = getTeamVision()
			Unit.visible_tiles = vision_info.visible_tiles
			onProcessUnitVision(Unit, vision_info.unit_vision, old_ally_vision)
			if apply_greyscale: onApplyGreyscale()
		1:
			onApplyVisionModeGreyscale(ActiveUnitVision)
	LevelUI.on_update_vision()

func onProcessUnitVision(Unit: UnitGD, unit_vision: Dictionary, old_ally_vision: Array = [], trigger_ui: bool = true) -> void:
	for _Unit in unit_vision.keys():
		match unit_vision[_Unit]:
			"Enter":
				if trigger_ui: Units.onUnitEntersVision(Unit, _Unit, old_ally_vision)
				if Unit.Tile not in _Unit.visible_tiles:
					_Unit.visible_tiles.append(Unit.Tile)
			"Exit":
				if trigger_ui: Units.onUnitExitsVision(Unit, _Unit)
				_Unit.visible_tiles.erase(Unit.Tile)
				Unit.visible_tiles.erase(_Unit.Tile)
			"Regular":
				if Unit.Tile not in _Unit.visible_tiles:
					_Unit.visible_tiles.append(Unit.Tile)
func onApplyGreyscale() -> void:
	var dev := preload("res://static/dev/dev.tres")
	var ally_vision: Array = getTeamVision()
	if !dev.perma_vision:
		for Tile in Tiles.get_children():
			if Tile in ally_vision: Tiles.on_remove_tile_material(Tile, "Greyscale")
			else: Tiles.on_set_tile_material(Tile, "Greyscale")
	for Unit in Units.on_units(TeamRelationGD.new(1)): Unit.Model.setVisible(Unit.Tile in ally_vision)
func onApplyVisionModeGreyscale(Unit: UnitGD) -> void:
	if Unit != null:
		var ally_vision_crossover: Array = Unit.visible_tiles
		if Unit.team == 1:
			var ally_vision: Array = getTeamVision()
			ally_vision_crossover = ally_vision_crossover.filter(func(x: TileGD): return x in ally_vision)
		for _Unit in Units.all_units():
			setUnitVisionModeOccupy(_Unit, _Unit.Tile in ally_vision_crossover)
		
		for Tile in Tiles.get_children():
			if Tile in ally_vision_crossover: Tiles.on_remove_tile_material(Tile, "Greyscale")
			else: Tiles.on_set_tile_material(Tile, "Greyscale")
	else:
		for _Unit in Units.all_units(): setUnitVisionModeOccupy(_Unit, false)
	
func setUnitVisionModeOccupy(Unit: UnitGD, state: bool) -> void:
	if state: Tiles.on_remove_tile_material(Unit.Tile, "Greyscale")
	else: Tiles.on_set_tile_material(Unit.Tile, "Greyscale")
	Unit.Model.onSetOverrideMaterial("Regular" if state else "GreyInstant")

func isUnitInUnitVisionSafe(VisionUnit: UnitGD, ObservedUnit: UnitGD) -> bool:
	if VisionUnit.team == 0 or ObservedUnit.Tile in getTeamVision(): 
		if VisionUnit == ObservedUnit: return true
		return ObservedUnit in VisionUnit.getVisibleUnits()
	return false

var ActiveUnitVision: UnitGD
var vision_mode: int = 0 # 0 = default, 1 = unit_vision
func on_vision_mode_set(x: int) -> void:
	if x != vision_mode:
		if vision_mode == 1:
			var ally_vision: Array = getTeamVision()
			for Unit in Units.all_units():
				setUnitVisionModeOccupy(Unit, Unit.Tile in ally_vision)
				Unit.Model.onSetOverrideMaterial("Regular")
				
		vision_mode = x
		LevelUI.onVisionModeSet()
		onApplyGreyscale()
		
		if vision_mode == 1: setActiveUnitVision(SpectateCamera.SpectateUnit)
		else: setActiveUnitVision(null)
			
func setActiveUnitVision(Unit: UnitGD) -> void:
	if vision_mode == 1:
		if Unit != null and Unit.Tile in getTeamVision(): ActiveUnitVision = Unit
		else: ActiveUnitVision = SpectateCamera.SpectateUnit
		onApplyVisionModeGreyscale(ActiveUnitVision)

func onTileHovered(Tile: TileGD) -> void:
	if vision_mode == 1:
		var Unit: UnitGD = Units.unit_by_tile(Tile)
		if Unit == null and "MovementRange" in Tile.tile_outlines:
			Unit = PlayerManager.UnitSelected
		if Unit != null: setActiveUnitVision(Unit)
			
func onTileUnhovered(Tile: TileGD) -> void:
	if vision_mode == 1 and ActiveUnitVision != null and "MovementRange" not in ActiveUnitVision.Tile.tile_outlines:
		await get_tree().process_frame
		if Tiles.active_tile == null or ("MovementRange" not in Tiles.active_tile.tile_outlines and !Units.unit_by_tile(Tiles.active_tile)):
			setActiveUnitVision(null)

func on_player_end_turn_phase_start() -> void:
	on_vision_mode_set(0)
func onUnitAwakened(Unit: UnitGD) -> void:
	onRecalculateOthersVision(Unit)
func onDeathFinished(Unit: UnitGD) -> void:
	onRecalculateOthersVision(Unit)
func onRecalculateOthersVision(Unit: UnitGD) -> void:
	for _Unit in Units.all_units(Unit).filter(func(x: UnitGD): return x.Tile in Unit.visible_tiles):
		onRecalculateVision(_Unit, false)
	onApplyGreyscale()

func onUnits(team_relation: TeamRelationGD) -> Array:
	var ally_vision: Array = getTeamVision()
	return Units.on_units(team_relation).filter(func(x: UnitGD): return x.Tile in ally_vision)
	
