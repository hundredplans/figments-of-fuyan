class_name UnitsGD
extends Node3D

var GameEffects: GameEffectsGD
var VFX: VFXGD
var Deck: DeckGD
var SpectateCamera: Node3D
var GameState: GameStateGD
var Vision: VisionGD
var Random: RandomGD
var Tiles: TilesGD
var LevelMap: Node3D
var LevelUI: LevelUIGD
var Combat: CombatGD
var AIManager: AIManagerGD
var PlayerManager: PlayerManagerGD
var StatusManager: StatusManagerGD
var Hand: HandGD

@onready var Postmortem: Node3D = $Postmortem
@onready var FieldedUnits: Node3D = $FieldedUnits

var UnitScene: PackedScene = preload("res://scenes/screens/level_map/utility_nodes/units/unit.tscn")

const ARRIVE_EFFECT_DELAY_DURATION: float = 2
func onUnitAwakened(id: int, tool_id: int, effects: Array, team: int, rot: int, tile: TileGD) -> UnitGD:
	var Unit: UnitGD = onUnitAwakenedLoad(id, tool_id, effects, team, rot, tile)
	if Unit != null: await onUnitAwakenedProcess(Unit, tile)
	return Unit

func onUnitAwakenedLoad(id: int, tool_id: int, effects: Array, team: int, rot: int, tile: TileGD) -> UnitGD:
	if !unit_by_tile_bool(tile):
		var Unit: UnitGD = UnitScene.instantiate()
		FieldedUnits.add_child(Unit)
		Unit.onUnitAwakened(id, tool_id, effects, team, rot, tile)
		Unit.Model.unit_fell.connect(onUnitFell.bind(Unit))
		StatusManager.onUnitAwakened(Unit)
		Unit.onChangeTile(tile)
		return Unit
	return null
	
func onUnitAwakenedProcess(Unit: UnitGD, Tile: TileGD) -> void:
	Vision.onUnitAwakened(Unit)
	Unit.on_arrive(Unit.team == 0 or Unit.getVisibleEnemies().size() > 0)
	Unit.finished_awakening = true
	Combat.onArrive(Unit)
	onArrive(Unit)
	PlayerManager.onSetupAllyPassedTurns(Unit)
	Combat.onRecalculateTargetAbilities()
	await get_tree().process_frame
	Unit.occupy_tile(Tile)
	AIManager.getDangerList(Unit, all_units())
	
func onArrive(Unit: UnitGD) -> void:
	var armor: TraitGD = Combat.onFindTrait(Unit, TraitGD.ARMOR)
	if armor != null: StatusManager.onAddUnitFX(Unit, "Armor", AppliedByGD.new("Trait"), armor.armor)
	
func onMassUnitsAwakened(tiles: Array, enemy_ids: Array) -> void:
	var units: Array = []
	for i in range(tiles.size()):
		units.append(onUnitAwakenedLoad(enemy_ids[i], 0, [], 1, tiles[i].obj.rotation, tiles[i]))
	for i in range(tiles.size()): onUnitAwakenedProcess(units[i], tiles[i])

func onStartPhaseStart() -> void:
	var allowed_spawns: Array = range(7, 25)
	var enemy_tiles: Array = Tiles.on_is_type_get_tiles("Enemy", "obj")
	var enemy_spawns: Array = []
	
	for i in range(enemy_tiles.size()):
		enemy_spawns.append(allowed_spawns[randi() % allowed_spawns.size()])
	onMassUnitsAwakened(enemy_tiles, enemy_spawns)

func unit_by_tile_team_bool(Tile: TileGD, team: int) -> bool:
	return FieldedUnits.get_children().any(func(x: UnitGD): return x.Tile == Tile and x.team == team)
func unit_by_tile_bool(Tile: TileGD) -> bool:
	return FieldedUnits.get_children().any(func(x: UnitGD): return x.Tile == Tile)

func unit_by_tile(Tile: TileGD) -> UnitGD:
	for Unit in FieldedUnits.get_children():
		if Tile == Unit.Tile: return Unit
	return null

func all_units(exclude: UnitGD = null) -> Array:
	return FieldedUnits.get_children().filter(func(x: UnitGD): return !x.is_dead and x != exclude )

func on_units(team_relation: TeamRelationGD = TeamRelationGD.new(0, "Ally")) -> Array:
	return FieldedUnits.get_children().filter(func(x: UnitGD): return !x.is_dead and x.team == team_relation.onTeam())

func on_awakened_units(team_relation: TeamRelationGD = TeamRelationGD.new(0, "Ally")) -> Array:
	return on_units(team_relation).filter(func(x: UnitGD): return x.finished_awakening)

func on_match_team_relation(unit: UnitGD, team: int, relation: String) -> bool:
	return (unit.team == team and relation == "Ally") or (unit.team != team and relation == "Enemy") or relation == "Any"

func onUnitEntersVision(Unit: UnitGD, _Unit: UnitGD, old_ally_vision: Array) -> void:
	if Unit.team == 0 and _Unit.team == 1 and _Unit.Tile not in old_ally_vision:
		if Unit.finished_awakening: AudioMaster.play_sfx("TrumpetKuba")
		PlayerManager.on_enemy_unit_enters_vision(_Unit, Unit)
	Combat.onOngoingAbilityUnit(Unit, _Unit, "EnterVision")
	Combat.onOngoingAbilityUnit(_Unit, Unit, "EnterVision")
	
func onUnitExitsVision(Unit: UnitGD, _Unit: UnitGD) -> void:
	if Unit.team == 0 and _Unit.team == 1:
		PlayerManager.on_enemy_unit_exits_vision(_Unit)
	Combat.onOngoingAbilityUnit(Unit, _Unit, "ExitVision")
	Combat.onOngoingAbilityUnit(_Unit, Unit, "ExitVision")
	
var movement_outline_tiles: Array = []
	
func onRemoveMovementOutlineTiles() -> void:
	for Tile in movement_outline_tiles:
		Tiles.setTileOutline(Tile, "PathHovered", true)
	movement_outline_tiles = []

func onUnitFell(DMG: int, scale_time: float, Unit: UnitGD) -> void:
	var AppliedBy := AppliedByGD.new("Height")
	var DMGInfo := Combat.onDMG(Unit, AppliedBy, DMG)
	if Unit.health > 0 and DMGInfo.HealthDMG > 0: on_descale_unit(Unit, scale_time)

const DROP_HEIGHT_SCALE_DOWN := Vector3(1, 0.05, 1)
func on_descale_unit(Unit: UnitGD, scale_time: float) -> void:
	var ScaleTween := create_tween()
	ScaleTween.tween_property(Unit, "scale", DROP_HEIGHT_SCALE_DOWN, scale_time)
	ScaleTween.finished.connect(on_unscale_unit.bind(Unit, scale_time))

func on_unscale_unit(Unit: UnitGD, scale_time: float) -> void:
	var ScaleTween := create_tween()
	ScaleTween.tween_property(Unit, "scale", Vector3.ONE, scale_time)

func onSpectatedInPlayerPhase(Unit: UnitGD) -> void:
	LevelUI.on_pass_unit_turn_button_state(Unit.team == 1 or Unit in PlayerManager.passed_turns)

func onAIPhaseStart() -> void:
	AIManager.onAIPhaseStart()

func onAIEndTurnPhaseStart() -> void:
	AIManager.onAIEndTurnPhaseStart()
	for Unit in all_units():
		Unit.turns_alive += 1

func setUnitStatus(Unit: UnitGD, status: int) -> void:
	StatusManager.setUnitStatusTurnStatus(Unit, status)
	if status == UnitGD.TURN_USED:
		GameEffects.onTriggerUnitGameFX(Unit, TriggerGD.TURN_PASSED)

func setPastPath(Unit: UnitGD, state: bool) -> void:
	for Tile in Unit.past_path_info:
		Tiles.setTileOutline(Tile, "PastPath", !state)
		
		if state: Tile.Effects.onPastPath(Unit.past_path_info[Tile][0], Unit.past_path_info[Tile][1])
		else: Tile.Effects.onRemovePastPath()
		
	Unit.past_path_set = state

func onFindClosestUnitFromUnits(Unit: UnitGD, units: Array) -> UnitGD:
	units.erase(Unit)
	units.sort_custom(sortUnitsByDistance.bind(Unit))
	if units.size() > 0: return units[0]
	return null

func onFindClosestAdjacentUnit(Unit: UnitGD, team_relation: TeamRelationGD) -> UnitGD:
	return onFindClosestUnitFromUnits(Unit, on_units(team_relation))

func sortUnitsByDistance(Unit: UnitGD, _Unit: UnitGD, __Unit: UnitGD) -> bool:
	return Tiles.tile_distance(Unit.Tile, __Unit.Tile) < Tiles.tile_distance(_Unit.Tile, __Unit.Tile)
