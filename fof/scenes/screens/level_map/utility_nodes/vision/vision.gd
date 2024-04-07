class_name VisionGD
extends Node3D

@onready var MouseRayCast: RayCast3D = $MouseRayCast

var SpectateCamera: Node3D
var LevelUI: LevelUIGD
var Units: UnitsGD
var Tiles: TilesGD
var GameState: Node
const VISION_RANGE: int = 5

var ally_vision: Array = []
var spawn_vision: Array = []
func on_recalculate_vision(Unit: UnitGD = null) -> void:
	var visible_tiles: Array = []
	var all_units: Array = Units.all_units()
	var ally_units: Array = Units.on_units()
	match vision_mode:
		0:
			if Unit != null:
				Unit.onCircleRay()
				for _Unit in all_units:
					if _Unit != Unit:
						var was_visible: bool = _Unit in Unit.visible_units
						var currently_visible: bool = Unit.visible_tiles.any(func(x: TileGD): return x == _Unit.Tile)
						if was_visible and !currently_visible:
							Unit.visible_units.erase(_Unit)
							_Unit.visible_units.erase(Unit)
							
							if _Unit.getVisibleEnemies().is_empty():
								Units.onUnitExitsAllyVision(Unit, _Unit)
								
						elif !was_visible and currently_visible:
							Unit.visible_units.append(_Unit)
							_Unit.visible_units.append(Unit)
							Units.onUnitMovementEntersVision(Unit, _Unit)
							
							if Unit.Tile not in _Unit.visible_tiles:
								_Unit.visible_tiles.append(Unit.Tile)
								
			for Tile in Tiles.get_children(): # Takes around 5 msec
				if ally_units.any(func(x: UnitGD): return x.visible_tiles.any(func(y: TileGD): return Tile == y)):
					visible_tiles.append(Tile)
				
			ally_vision = visible_tiles.duplicate()
		1:
			visible_tiles = Tiles.movement_paths.tiles.duplicate()
						
			if ActiveUnitVision != null and ActiveUnitVision.Tile in ally_vision:
				onUnitVisionModeCalculateVision(ActiveUnitVision, visible_tiles)
			elif SpectateCamera.SpectateUnit != null:
				onUnitVisionModeCalculateVision(SpectateCamera.SpectateUnit, visible_tiles)
			#else:
				#for _Unit in Units.all_units():
					#Tiles.on_set_tile_material(_Unit.Tile, \
					#"AllyOccupy" if _Unit.team == 0 else "EnemyOccupy")
			
			for _Unit in all_units:
				match _Unit.team:
					0: if _Unit.Tile not in visible_tiles: visible_tiles.append(_Unit.Tile)
					1: if _Unit.Tile in ally_vision: visible_tiles.append(_Unit.Tile)
			
		2:
			visible_tiles = spawn_vision
		3: # enemy vision
			if Unit != null:
				pass
			
	on_apply_visibility(visible_tiles)
	LevelUI.on_update_vision()

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
	
	#for _Unit in Units.all_units():
		#if _Unit.Tile not in visible_tiles:
			#print("Here")
			#Tiles.on_remove_tile_material(_Unit.Tile, "AllyOccupy" if _Unit.team == 0 else "EnemyOccupy")

func on_start_phase_start() -> void:
	for Tile in Tiles.get_children():
		if Tile.obj.id == 2:
			spawn_vision.append(Tile)
	
func on_apply_visibility(tiles: Array) -> void:
	for Tile in Tiles.get_children(): 
		if Tile not in tiles: Tiles.on_set_tile_material(Tile, "Greyscale")
		else: Tiles.on_remove_tile_material(Tile, "Greyscale")
	for Unit in Units.on_units(0, "Enemy"): Unit.visible = Unit.Tile in tiles

func is_unit_in_vision(Unit: UnitGD) -> bool: # two diff visions for the two teams
	return Units.on_units(Unit.team, "Enemy").any(func(x: UnitGD): return Unit in x.visible_units)

func isUnitInUnitVisionSafe(VisionUnit: UnitGD, ObservedUnit: UnitGD, include_self: bool) -> bool:
	if VisionUnit.team == 0 or ObservedUnit.Tile in ally_vision: 
		return isUnitInUnitVision(VisionUnit, ObservedUnit, include_self)
	return false

func isUnitInUnitVision(VisionUnit: UnitGD, ObservedUnit: UnitGD, include_self: bool) -> bool:
	if VisionUnit != null and ObservedUnit != null:
		if VisionUnit == ObservedUnit: return include_self
		return ObservedUnit in VisionUnit.visible_units
		
	return false

var vision_mode: int = 0 # 0 = default, 1 = unit_vision, 2 = spawn_vision
func on_vision_mode_set(x: int) -> void:
	if x != vision_mode:
		if vision_mode == 1:
			for Unit in Units.all_units():
				Tiles.on_set_tile_material(Unit.Tile, "AllyOccupy" if Unit.team == 0 else "EnemyOccupy")
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
		
		await get_tree().create_timer(0.02).timeout
		
		if Tiles.active_tile == null or !("MovementRange" in Tiles.active_tile.tile_state):
			on_recalculate_vision()
		else: ActiveUnitVision = keep_unit

func on_player_end_turn_phase_start() -> void:
	on_vision_mode_set(0)
