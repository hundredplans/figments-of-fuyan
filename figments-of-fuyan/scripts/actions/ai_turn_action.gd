class_name AITurnAction extends Action

var Card: CardGD
var roll_for_ignore_behaviour: bool

const IGNORE_BEHAVIOUR_CHANCE: float = 0.15
const DEFAULT_FIGHT_LOGIC_SCRIPT_PATH: String = "res://scripts/fof_info/cards/extra/behaviours/default_fight_logic.gd"
const TOP_AMOUNT: int = 5
const TOP_ODDS: Dictionary = {
	1: 0.5,
	2: 0.25,
	3: 0.15,
	4: 0.075,
	5: 0.025
}

var pacifist: bool # For when coconut crab wakes up

func _init(_Card: CardGD, _roll_for_ignore_behaviour: bool = false, _pacifist: bool = false) -> void:
	super()
	Card = _Card
	roll_for_ignore_behaviour = _roll_for_ignore_behaviour
	pacifist = _pacifist
		
func onPostAction() -> void:
	var tiles: Array = Game.getsetMovementRange(Card)
	tiles.erase(Card.Tile)
	
	var allies: Array = Card.getVisibleFieldCardsAllies()
	var enemies: Array = Card.getVisibleFieldCardsEnemies()
	
	if pacifist:
		var enemy_tiles: Array = enemies.map(func(x: CardGD): return x.getTile())
		tiles = tiles.filter(func(x: TileGD): return x not in enemy_tiles)
	
	var DFL := DefaultFightLogic.new(Card, tiles, enemies, allies, pacifist)
	var dfl_data: DFLData = DFL.getTilesDFL()
	
	if dfl_data.KillTile != null:
		onTileChosen(dfl_data.KillTile, DFL)
		return
	
	var tiles_to_value: Dictionary = onApplyBehaviours(Card, enemies, allies, tiles, dfl_data)
		
	var tiles_sorted_by_value: Array = getTilesSortedByValue(tiles_to_value)
	var index: int = min(Random.getRandomKeyVariant(TOP_ODDS), tiles_sorted_by_value.size())
	if index > 0: # If the tile is valid
		onTileChosen(tiles_sorted_by_value[index - 1], DFL)
		return
		
	if onCheckActiveEffects(Card, DFL):
		return
		
	# If no Tile is chosen
	onPushAction([ChangeTurnStateAction.new(Card, Game.TurnStates.ACTIVE), MovementFinishAction.new(Card, [])])

func getLogInfo() -> Array:
	return ["Card: " + Card.info.name]

func onTileChosen(Tile: TileGD, DFL: DefaultFightLogic) -> void:
	var path: Array = Tile.getMovementPathTiles()
	path = DFL.onTileChosenGetUpdatedAttackablePath(path)
	DFL.setPath(path)
	
	if onCheckActiveEffects(Card, DFL):
		return
	
	var actions: Array = [ChangeTurnStateAction.new(Card, Game.TurnStates.ACTIVE),
		MovementAction.new(Card, path)]
	onPushAction(actions)
		
# Bool if to use active effect and retry behaviour
func onCheckActiveEffects(Card: CardGD, DFL: DefaultFightLogic) -> bool:
	var tool_active_effects: Array = Card.Tool.getActiveEffects() if Card.Tool != null else []
	var active_effects: Array = Card.getActiveEffects() + tool_active_effects
	
	for IObject in Game.get_tree().get_nodes_in_group("LevelIObjectsGD")\
		.filter(func(x: ObjectGD): return !x.is_queued_for_deletion()):
		active_effects += IObject.getValidActiveEffects(Card)
		
	for active_effect in active_effects:
		var active_effect_tiles: ActiveEffectTiles = active_effect.owner.onAIAbilityCheckerDefault(active_effect)\
			if active_effect.owner is not IObjectGD else active_effect.owner.onAIAbilityCheckerDefault(active_effect, Card)
		if active_effect_tiles == null: continue
		
		var Tile: TileGD = active_effect.owner.onAIAbilityChecker(active_effect, active_effect_tiles, DFL)
		if Tile == null: continue
		
		var actions: Array = [ChangeTurnStateAction.new(Card, Game.TurnStates.ACTIVE),\
			ActiveEffectUsedAction.new(active_effect, Tile, active_effect_tiles, Card),\
			MovementFinishAction.new(Card, [])]
		onPushAction(actions)
		return true
	return false
	
func getTilesSortedByValue(tiles_to_value: Dictionary) -> Array:
	var tiles_sorted_by_value: Array = tiles_to_value.keys()
	tiles_sorted_by_value.sort_custom(func(x: TileGD, y: TileGD): return tiles_to_value[x] > tiles_to_value[y])
	
	tiles_sorted_by_value.resize(TOP_AMOUNT)
	tiles_sorted_by_value = tiles_sorted_by_value.filter(func(x: TileGD): return x != null and tiles_to_value[x] >= 0)
	return tiles_sorted_by_value
	
func onApplyBehaviours(Card: CardGD, enemies: Array, allies: Array, tiles: Array, dfl_data: DFLData) -> Dictionary:
	var tiles_to_value: Dictionary = dfl_data.tiles_to_value
	var ignore_behaviour_roll: bool = Random.rollFloat(IGNORE_BEHAVIOUR_CHANCE) if roll_for_ignore_behaviour else Card.last_ignore_behaviour_roll
	Card.last_ignore_behaviour_roll = ignore_behaviour_roll
	
	if !ignore_behaviour_roll:
		var is_in_combat: bool = !enemies.is_empty()
		var behaviours: Array = Card.info.archetype.behaviours.map(func(x: GDScript): var behaviour := Behaviour.new(); behaviour.set_script(x); return behaviour)
		behaviours = behaviours.filter(func(x: Behaviour): return (x.isCombatBehaviour() and is_in_combat) or (x.isOutOfCombatBehaviour() and !is_in_combat))
		
		var behaviour_amount: float = behaviours.size() + 1.0
		for behaviour_script in Card.info.archetype.behaviours:
			var behaviour := Behaviour.new()
			behaviour.script = behaviour_script
			var behaviour_tiles_to_value: Dictionary = behaviour.getCombatTiles(Card, tiles, enemies, allies) if is_in_combat else\
				behaviour.getOutOfCombatTiles(Card, tiles, allies, enemies)
			
			for Tile in behaviour_tiles_to_value:
				tiles_to_value[Tile] += behaviour_tiles_to_value[Tile]
				
		for Tile in tiles_to_value:
			tiles_to_value[Tile] /= behaviour_amount
	return tiles_to_value
