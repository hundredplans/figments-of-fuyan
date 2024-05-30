class_name VisionGD
extends Node3D

@onready var MouseRayCast: RayCast3D = $MouseRayCast

var SpectateCamera: Node3D
var LevelUI: LevelUIGD
var Units: UnitsGD
var Tiles: TilesGD
var GameState: Node
const VISION_RANGE: int = 5

var spawn_tiles: Array
var enemy_vision: Array = []
var ally_vision: Array = []
func on_recalculate_vision(Unit: UnitGD = null) -> void:
	var all_units: Array = Units.all_units()
	var enemy_units: Array = Units.on_units(1)
	var ally_units: Array = Units.on_units()
	match vision_mode:
		0: # Takes around 20-30 msec to complete
			ally_vision = []
			enemy_vision = []
			var og_unit_vision: Array = [] 
			if Unit != null:
				og_unit_vision = Unit.visible_tiles.duplicate()
				Unit.onCircleRay()
			
			ally_vision += spawn_tiles.duplicate()
			# Usually takes 10-30msec
			for Tile in Tiles.get_children():
				if ally_units.any(func(x: UnitGD): return Tile in x.visible_tiles):
					ally_vision.append(Tile)
				if enemy_units.any(func(x: UnitGD): return Tile in x.visible_tiles):
					enemy_vision.append(Tile)
			# Usualy takes between 5-10msec
			onCalculateVisionUpdate(Unit, og_unit_vision)
			on_apply_visibility(ally_vision)
			# Sometimes takes up to 50msec?
		1:
			var visible_tiles: Array = []
			var SpectateUnit: UnitGD = SpectateCamera.SpectateUnit
			if ActiveUnitVision != null and ActiveUnitVision.Tile in ally_vision:
				onUnitVisionModeCalculateVision(ActiveUnitVision, visible_tiles)
			elif SpectateUnit != null:
				onUnitVisionModeCalculateVision(SpectateUnit, visible_tiles)
				
			for _Unit in all_units:
				setUnitVisionModeOccupy(_Unit, _Unit.Tile in visible_tiles)
					
			onApplyVisionModeVisibility(visible_tiles)
			
	LevelUI.on_update_vision()

func onCalculateVisionUpdate(Unit: UnitGD, og_unit_vision: Array) -> void:
	if Unit != null:
		for _Unit in Units.all_units(Unit):
			var was_visible: bool = _Unit.Tile in og_unit_vision
			var gain_visible: bool = _Unit.Tile in Unit.visible_tiles
			if (was_visible and not gain_visible) or (gain_visible and not was_visible):
				if was_visible: Units.onUnitExitsVision(Unit, _Unit)
				elif gain_visible: Units.onUnitEntersVision(Unit, _Unit)

func onExitTile(Unit: UnitGD, OriginTile: TileGD, DestinationTile: TileGD) -> void:
	for _Unit in Units.all_units(Unit):
		if OriginTile in _Unit.visible_tiles and !(OriginTile in _Unit.height_adjacent_tiles) and !_Unit.onRayTile(OriginTile):
			_Unit.visible_tiles.erase(OriginTile)
		if DestinationTile not in _Unit.visible_tiles and Tiles.tile_distance(DestinationTile, _Unit.Tile) <= 5:
			if _Unit.onRayEnemyUnit(Unit, true): _Unit.visible_tiles.append(DestinationTile)
	
func setUnitVisionModeOccupy(Unit: UnitGD, state: bool) -> void:
	if state:
		Tiles.on_remove_tile_material(Unit.Tile, "Greyscale")
	else:
		Tiles.on_set_tile_material(Unit.Tile, "Greyscale")

func onUnitVisionModeCalculateVision(Unit: UnitGD, visible_tiles: Array) -> void:
	match Unit.team:
		0:
			for Tile in Tiles.get_children():
				if Tile in Unit.visible_tiles:
					visible_tiles.append(Tile)
		1:
			for Tile in ally_vision:
				if Tile in Unit.visible_tiles:
					visible_tiles.append(Tile)
	
	for _Unit in Units.all_units():
		_Unit.Model.onSetOverrideMaterial("Regular" if _Unit.Tile in visible_tiles else "GreyInstant")
	
func onApplyVisionModeVisibility(visible_tiles: Array) -> void:
	on_apply_visibility(visible_tiles)
	for Unit in Units.all_units(): Unit.Model.setVisible(Unit.Tile in ally_vision)
	
func on_apply_visibility(tiles: Array) -> void:
	for Tile in Tiles.get_children(): 
		if Tile not in tiles: Tiles.on_set_tile_material(Tile, "Greyscale")
		else: Tiles.on_remove_tile_material(Tile, "Greyscale")
	for Unit in Units.on_units(0, "Enemy"): Unit.Model.setVisible(Unit.Tile in tiles)

func is_unit_in_vision(Unit: UnitGD) -> bool:
	if Unit.Tile in spawn_tiles: return true
	return Units.on_units(Unit.team, "Enemy").any(func(x: UnitGD): return Unit in x.getVisibleUnits())

func isUnitInUnitVisionSafe(VisionUnit: UnitGD, ObservedUnit: UnitGD, include_self: bool) -> bool:
	if VisionUnit.team == 0 or ObservedUnit.Tile in ally_vision: 
		return isUnitInUnitVision(VisionUnit, ObservedUnit, include_self)
	return false

func isUnitInUnitVision(VisionUnit: UnitGD, ObservedUnit: UnitGD, include_self: bool) -> bool:
	if VisionUnit != null and ObservedUnit != null:
		if VisionUnit == ObservedUnit: return include_self
		return ObservedUnit in VisionUnit.getVisibleUnits()
		
	return false

var vision_mode: int = 0 # 0 = default, 1 = unit_vision, 2 = spawn_vision
func on_vision_mode_set(x: int) -> void:
	if x != vision_mode:
		if vision_mode == 1:
			for Unit in Units.all_units():
				setUnitVisionModeOccupy(Unit, Unit.Tile in ally_vision)
				Unit.Model.onSetOverrideMaterial("Regular")
		ActiveUnitVision = null
		vision_mode = x
		LevelUI.onVisionModeSet()
		on_recalculate_vision()

var ActiveUnitVision: UnitGD
func on_tile_hovered(Tile: TileGD) -> void:
	if vision_mode == 1 and ActiveUnitVision == null:
		var Unit: UnitGD = Units.unit_by_tile(Tile)
		if Unit == null and Tile in Tiles.path_hovered_info.tiles:
			Unit = Units.PlayerManager.UnitSelected
		
		if Unit != null:
			ActiveUnitVision = Unit
			on_recalculate_vision()
		
func on_tile_unhovered(__: TileGD) -> void:
	if vision_mode == 1 and ActiveUnitVision != null:
		var keep_unit: UnitGD = ActiveUnitVision
		ActiveUnitVision = null
		
		await get_tree().create_timer(0.001).timeout
		
		if Tiles.active_tile == null or !("MovementRange" in Tiles.active_tile.tile_outlines):
			on_recalculate_vision()
		else: ActiveUnitVision = keep_unit

func on_player_end_turn_phase_start() -> void:
	on_vision_mode_set(0)

func onStartPhaseStart() -> void:
	spawn_tiles = Tiles.on_is_type_get_tiles("Spawn", "obj")
