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
var LevelMap: LevelMapGD
var LevelUI: LevelUIGD
var Combat: CombatGD
var AIManager: AIManagerGD
var PlayerManager: PlayerManagerGD
var StatusManager: StatusManagerGD
var TriggerManager: TriggerManagerGD
var ActionManager: ActionManagerGD
var Hand: HandGD
var NeutralManager: NeutralManagerGD

@onready var Postmortem: Node3D = $Postmortem
@onready var FieldedUnits: Node3D = $FieldedUnits

var UnitScene: PackedScene = preload("res://scenes/screens/level_map/utility_nodes/units/unit.tscn")

const ARRIVE_EFFECT_DELAY_DURATION: float = 2
func onUnitAwakened(id: int, team: int, rot: int, tile: TileGD, tool: ToolGD = null) -> UnitGD:
	var Unit: UnitGD = onUnitAwakenedLoad(id, team, rot, tile)
	if Unit != null: await onUnitAwakenedProcess(Unit, tile, tool)
	return Unit

func onUnitAwakenedLoad(id: int, team: int, rot: int, tile: TileGD) -> UnitGD:
	if !unit_by_tile_bool(tile):
		var Unit: UnitGD = UnitScene.instantiate()
		FieldedUnits.add_child(Unit)
		Unit.onUnitAwakened(id, team, rot, tile)
		Unit.Model.unit_fell.connect(onUnitFell.bind(Unit))
		StatusManager.onUnitAwakened(Unit)
		Unit.onChangeTile(tile)
		NeutralManager.onUnitAwakened(Unit)
		return Unit
	return null
	
func onUnitAwakenedProcess(Unit: UnitGD, Tile: TileGD, Tool: ToolGD = null) -> void:
	Vision.onUnitAwakened(Unit)
	Unit.on_arrive(Unit.team == 0 or Unit.getVisibleEnemies().size() > 0)
	Unit.finished_awakening = true
	Combat.onArrive(Unit)
	PlayerManager.onSetupAllyPassedTurns(Unit)
	PlayerManager.onRefreshAbilitySelect()
	await get_tree().process_frame
	Unit.occupy_tile(Tile)
	AIManager.getDangerList(Unit, all_units())
	Unit.onEquipTool(Tool)
	TriggerManager.onUnitTrigger(Unit, TriggerGD.AWAKEN)
		
func onMassUnitsAwakened(tiles: Array, enemy_ids: Array, team: int = 1) -> Array:
	var units: Array = []
	for i in range(tiles.size()):
		units.append(onUnitAwakenedLoad(enemy_ids[i], team, tiles[i].obj.rotation, tiles[i]))
	for i in range(tiles.size()): onUnitAwakenedProcess(units[i], tiles[i])
	return units

func onStartPhaseStart() -> void:
	var allowed_spawns: Array = range(7, 25)
	var enemy_tiles: Array = Tiles.on_is_type_get_tiles("Enemy", "obj")
	var enemy_spawns: Array = []
	
	for i in range(enemy_tiles.size()):
		enemy_spawns.append(allowed_spawns[randi() % allowed_spawns.size()])
	onMassUnitsAwakened(enemy_tiles, enemy_spawns)
	
	var neutral_tiles: Array = Tiles.on_is_type_get_tiles("Neutral", "obj")
	var neutral_spawns: Array = []
	allowed_spawns = range(27, 30)
	
	for i in range(neutral_tiles.size()):
		neutral_spawns.append(allowed_spawns[randi() % allowed_spawns.size()])
	onMassUnitsAwakened(neutral_tiles, neutral_spawns, 2)

func unit_by_tile_team_bool(Tile: TileGD, team: int) -> bool:
	return FieldedUnits.get_children().any(func(x: UnitGD): return x.Tile == Tile and x.team == team)
	
func unit_by_tile_bool(Tile: TileGD) -> bool:
	return FieldedUnits.get_children().any(func(x: UnitGD): return x.Tile == Tile)

func unit_by_tile(Tile: TileGD) -> UnitGD:
	for Unit in FieldedUnits.get_children():
		if Tile == Unit.Tile: return Unit
	return null

func getAliveDyingUnits() -> Array: return FieldedUnits.get_children() + Postmortem.get_children().filter(func(x: UnitGD): return !x.finished_last_will)

func all_units(exclude: UnitGD = null) -> Array:
	return FieldedUnits.get_children().filter(func(x: UnitGD): return !x.is_dead and x != exclude )

func on_units(team_relation: TeamRelationGD = TeamRelationGD.new(0, "Ally")) -> Array:
	return FieldedUnits.get_children().filter(func(x: UnitGD): return !x.is_dead and x.team == team_relation.onTeam())

func on_awakened_units(team_relation: TeamRelationGD = TeamRelationGD.new(0, "Ally")) -> Array:
	return on_units(team_relation).filter(func(x: UnitGD): return x.finished_awakening)

func on_match_team_relation(unit: UnitGD, team: int, relation: String) -> bool:
	return (unit.team == team and relation == "Ally") or (unit.team != team and relation == "Enemy") or relation == "Any"

func onUnitEntersVision(Unit: UnitGD, _Unit: UnitGD, old_ally_vision: Array) -> void:
	if !Unit.is_dead or _Unit.is_dead:
		if Unit.team == 0 and _Unit.team == 1 and _Unit.Tile not in old_ally_vision:
			if Unit.finished_awakening: AudioMaster.play_sfx("TrumpetKuba")
			PlayerManager.on_enemy_unit_enters_vision(_Unit, Unit)
		TriggerManager.onUnitTrigger(Unit, TriggerGD.ENTER_VISION, VisionTriggerInfoGD.new(_Unit))
		TriggerManager.onUnitTrigger(_Unit, TriggerGD.ENTER_VISION, VisionTriggerInfoGD.new(Unit))
	
func onUnitExitsVision(Unit: UnitGD, _Unit: UnitGD) -> void:
	if !Unit.is_dead or _Unit.is_dead:
		if Unit.team == 0 and _Unit.team == 1:
			PlayerManager.on_enemy_unit_exits_vision(_Unit)
			
		TriggerManager.onUnitTrigger(Unit, TriggerGD.EXIT_VISION, VisionTriggerInfoGD.new(_Unit))
		TriggerManager.onUnitTrigger(_Unit, TriggerGD.EXIT_VISION, VisionTriggerInfoGD.new(Unit))
	
var movement_outline_tiles: Array = []
	
func onRemoveMovementOutlineTiles() -> void:
	for Tile in movement_outline_tiles:
		Tiles.setTileOutline(Tile, "PathHovered", true)
	movement_outline_tiles = []

func onUnitFell(DMG: int, scale_time: float, Unit: UnitGD) -> void:
	var AppliedBy := AppliedByGD.new(AppliedByGD.HEIGHT)
	var DMGInfos: Dictionary = Combat.onDMG(Unit, AppliedBy, DMG)
	if Unit.health > 0 and DMGInfos[Unit].HealthDMG > 0: on_descale_unit(Unit, scale_time)

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

func onAIEndTurnPhaseStart() -> void:
	AIManager.onAIEndTurnPhaseStart()
	for Unit in all_units():
		Unit.turns_alive += 1

func setUnitStatus(Unit: UnitGD, status: int) -> void:
	StatusManager.setUnitStatusTurnStatus(Unit, status)
	if status == UnitGD.TURN_USED:
		TriggerManager.onUnitTrigger(Unit, TriggerGD.TURN_PASSED)
		

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

func onFindAdjacentUnits(Obj: Variant, distance: int) -> Array:
	return Tiles.onFindUnitAdjacentTiles(Obj, distance).filter(func(x: TileGD): return x.Unit != null).map(func(x: TileGD): return x.Unit)
	
func changeStats(info: Variant) -> void:
	# Pass in either an array of StatInfoGD or StatInfoGD
	var stats: StatsGD = StatsGD.new(info)
	var array: Array = []
	for stat_info in stats.array.filter(func(x: StatInfoGD): return !x.Unit.is_dead):
		Helper.onCreateChildReferences(stat_info)
		stat_info.onApplyModifiers()
		var diff: int = stat_info.Unit.changeStats(stat_info)
		if diff != 0: array.append({"stat_info": stat_info, "diff": diff})
	
	var next_turn_stats_units: Array = []
	for item in array:
		var stat_info: StatInfoGD = item.stat_info
		var Unit: UnitGD = stat_info.Unit
		if stat_info.turns == 1 and Unit not in next_turn_stats_units: next_turn_stats_units.append(Unit)
		var diff: int = item.diff
		var color: String = getStatColor(Unit, stat_info.stat_type)
		var stat_name: String = item.stat_info.getStatName()
		
		StatusManager.onUpdateStats(Unit, stat_name, color)
		var vis: bool = Unit.isVis()
		TriggerManager.onUnitTrigger(Unit, TriggerGD.STAT_CHANGE, StatChangeTriggerInfoGD.new(stat_info))
		if vis and stat_info.show_change: VFX.onCreateStatParticle(diff, stat_name.to_lower(), Unit.Tile, Unit.height.top / 2)
		
		Unit.onAddToStatHistory(stat_info)
		if stat_name == "Speed" and LevelMap.verifyLock(LevelMap.NULL_VERIFY): PlayerManager.onRefreshMovementRange(Unit)
	
	for Unit in next_turn_stats_units: onNextTurnStats(Unit)
	
func onHandPhaseStart() -> void:
	for Unit in on_units():
		onStatTurnPassed(Unit)
	
func onAIPhaseStart() -> void:
	for Unit in on_units(TeamRelationGD.new(1)):
		onStatTurnPassed(Unit)
	
func onStatTurnPassed(Unit: UnitGD) -> void:
	# 0's are not removed but are not accounted for either, they are treated as gone, -1 is infinite
	var stat_history: Array = Unit.stat_history.filter(func(x: StatInfoGD): return x.turns > 0)
	for stat_info in stat_history:
		stat_info.turns -= 1
		if stat_info.turns == 0:
			changeStats(stat_info.getReverse() if !stat_info.is_delayed else stat_info.getDelayed())
			StatusManager.onRemoveBuffNextTurn(stat_info)
			
	onNextTurnStats(Unit)
	
func onDelayedStats(stat_info: StatInfoGD) -> void:
	stat_info.Unit.onAddToStatHistory(stat_info)
	onNextTurnStats(stat_info.Unit)
	
var next_turn_stats: Array = []
func onNextTurnStats(Unit: UnitGD) -> void:
	var AppliedBy := AppliedByGD.new()
	var stats: Dictionary = {StatsGD.ATTACK: null, StatsGD.HEALTH: null, StatsGD.BOTH_HEALTH: null, StatsGD.BOTH_SPEED: null}
	
	for stat_info in Unit.stat_history.filter(func(x: StatInfoGD): return x.turns == 1):
		if stats.has(stat_info.stat_type):
			if stats[stat_info.stat_type] == null: stats[stat_info.stat_type] = StatInfoGD.new(stat_info.Unit, AppliedBy, stat_info.stat_type, stat_info.value, 1)
			else: stats[stat_info.stat_type].add(stat_info.value)
		else: print_debug("You are trying to temporarily add to an illegal stat!")
		
	next_turn_stats = stats.values().filter(func(x: StatInfoGD): return x != null and x.value != 0)
	StatusManager.onRefreshNextTurnStats(next_turn_stats)
	for stat_info in next_turn_stats:
		StatusManager.onRemoveBuffNextTurn(stat_info)
		StatusManager.onCreateBuffNextTurn(stat_info)
	
# This is the color of the stat not the buff
func getStatColor(Unit: UnitGD, stat_type: int) -> String:
	match stat_type:
		StatsGD.ATTACK:
			if Unit.attack > Unit.base_card.attack: return "GREEN"
			elif Unit.attack < Unit.base_card.attack: return "RED"
		StatsGD.HEALTH, StatsGD.MAX_HEALTH, StatsGD.BOTH_HEALTH:
			if Unit.health < Unit.max_health: return "RED"
			elif Unit.health > Unit.base_card.health: return "GREEN"
		StatsGD.CURRENT_SPEED, StatsGD.MAX_SPEED, StatsGD.BOTH_SPEED:
			if Unit.max_speed < Unit.base_card.speed: return "RED"
			elif Unit.speed > Unit.base_card.speed: return "GREEN"
	return "BASE"

func getAdjacentUnits(Tile: TileGD, distance: int = 1, search_elevation: bool = false, tiles: Array = Tiles.get_children()) -> Array:
	return Tiles.getAdjacentTiles(Tile, distance, search_elevation, tiles).map(func(x: TileGD): return x.Unit).filter(func(y: UnitGD): return y != null)
	
