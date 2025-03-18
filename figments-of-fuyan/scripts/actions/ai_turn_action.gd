class_name AITurnAction extends Action

var Card: CardGD
var is_first_ai_turn: bool

const IGNORE_BEHAVIOUR_CHANCE: float = 0.15
const RECEIVER_ARCHETYPE_PATH: String = "res://resources/fof/archetypes/receiver.tres"
const ADVENTURER_ARCHETYPE_PATH: String = "res://resources/fof/archetypes/adventurer.tres"
const BRUTE_ARCHETYPE_PATH: String = "res://resources/fof/archetypes/brute.tres"
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
var previous_allies: Array
var previous_enemies: Array
var is_end_use_type_boss: bool

func _init(_Card: CardGD, _is_first_ai_turn: bool = false, _pacifist: bool = false, _previous_allies: Array = [], _previous_enemies: Array = []) -> void:
	super()
	Card = _Card
	is_first_ai_turn = _is_first_ai_turn
	pacifist = _pacifist
	previous_allies = _previous_allies
	previous_enemies = _previous_enemies
		
func onPostAction() -> void:
	if Card is EpicCardGD and Card.boss_datastore.boss_intent_used_this_turn: return
	
	pacifist = pacifist if (Card.attack > 0 or Card.getStatusEffect(4) != null) else true # If no attack or disarmed
	var tiles: Array = Game.getsetMovementRange(Card)
	tiles.erase(Card.Tile)
	
	var allies: Array = Card.getVisibleFieldCardsAllies()
	var enemies: Array = Card.getVisibleFieldCardsEnemies()
	
	allies += previous_allies.filter(func(x: CardGD): return x not in allies)
	enemies += previous_enemies.filter(func(x: CardGD): return x not in enemies)
	
	enemies = enemies.filter(func(x: CardGD): return x.isAlive())
	allies = allies.filter(func(x: CardGD): return x.isAlive())
	
	# Revealed enemies in the unit's vision range
	enemies += Game.get_tree().get_nodes_in_group("FieldCardsGD").filter(\
		func(x: CardGD): return \
			x.isEnemy(Card.team) and \
			x.isRevealed(Card.team) and \
			x not in enemies and \
			Game.getCoordsDistance(x.getTile().getCoords(), Card.getTile().getCoords()) <= Card.getVisionRange())
	
	if Card is not EpicCardGD: onDefaultAITurn(enemies, allies, tiles)
	else: onBossAITurn(enemies, allies, tiles)

func onDefaultAITurn(enemies: Array, allies: Array, tiles: Array) -> void:
	if Card.ai_datastore.isReceiver() and !enemies.is_empty():
		Card.ai_datastore.setIsReceiver(false)

	if pacifist:
		var enemy_tiles: Array = enemies.map(func(x: CardGD): return x.getTile())
		tiles = tiles.filter(func(x: TileGD): return x not in enemy_tiles)
	
	var DFL := DefaultFightLogic.new(Card, tiles, enemies, allies, pacifist)
	Card.ai_datastore.DFL = DFL
	
	var dfl_data: DFLData = DFL.getTilesDFL()
	
	onCheckCallForHelp(allies, enemies)
	
	if !dfl_data.kill_path.is_empty():
		onKillPathChosen(dfl_data.kill_path, DFL, allies, enemies)
		return
	
	var tiles_to_value: Dictionary = onApplyBehaviours(Card, enemies, allies, tiles, dfl_data)
	var tiles_sorted_by_value: Array = getTilesSortedByValue(tiles_to_value)
	var index: int = min(Random.getRandomKeyVariant(TOP_ODDS), tiles_sorted_by_value.size())
	if index > 0: # If the tile is valid
		onTileChosen(tiles_sorted_by_value[index - 1], DFL, allies, enemies)
		return
		
	if Card.onAICheckActiveEffects(DFL, allies, enemies):
		return
		
	# If no Tile is chosen
	onPushAction([ChangeTurnStateAction.new(Card, Game.TurnStates.ACTIVE), MovementFinishAction.new(Card, [], allies, enemies)])

func onBossAITurn(enemies: Array, allies: Array, tiles: Array) -> void:
	var use_type := (EpicCardGD.UseType.START if is_first_ai_turn else EpicCardGD.UseType.RECALCULATE) if !is_end_use_type_boss else EpicCardGD.UseType.END
	Card.onUseBossIntent(enemies, allies, tiles, use_type)

func getLogInfo() -> Array:
	return ["Card: " + Card.info.name]

func onTileChosen(Tile: TileGD, DFL: DefaultFightLogic, allies: Array, enemies: Array) -> void:
	var path: Array = Tile.getMovementPathTiles()
	path = DFL.onTileChosenGetUpdatedAttackablePath(path)
	DFL.setPath(path)
	
	if Card.onAICheckActiveEffects(DFL, allies, enemies):
		return
	
	var actions: Array = [ChangeTurnStateAction.new(Card, Game.TurnStates.ACTIVE),
		MovementAction.new(Card, path)]
	onPushAction(actions)
	
func onKillPathChosen(kill_path: Array, DFL: DefaultFightLogic, allies: Array, enemies: Array) -> void:
	DFL.setPath(kill_path)
	
	if Card.onAICheckActiveEffects(DFL, allies, enemies):
		return
		
	var actions: Array = [ChangeTurnStateAction.new(Card, Game.TurnStates.ACTIVE),
		MovementAction.new(Card, kill_path)]
	onPushAction(actions)
	
func getTilesSortedByValue(tiles_to_value: Dictionary) -> Array:
	for Tile in tiles_to_value:
		var tiles: Array = Tile.getMovementPathTilesSafe()
		if tiles.size() <= 2: continue # This is just the start and end tile
		
		for i in range(1, tiles.size() - 1):
			tiles_to_value[Tile] += tiles_to_value[tiles[i]]
		tiles_to_value[Tile] /= float(tiles.size() - 1)
		
	var tiles_sorted_by_value: Array = tiles_to_value.keys()
	tiles_sorted_by_value.sort_custom(func(x: TileGD, y: TileGD): return tiles_to_value[x] > tiles_to_value[y])
	
	tiles_sorted_by_value.resize(TOP_AMOUNT)
	tiles_sorted_by_value = tiles_sorted_by_value.filter(func(x: TileGD): return x != null and tiles_to_value[x] >= 0)
	return tiles_sorted_by_value
	
func onApplyBehaviours(BehaviourCard: CardGD, enemies: Array, allies: Array, tiles: Array, dfl_data: DFLData) -> Dictionary:
	var tiles_to_value: Dictionary = dfl_data.tiles_to_value
	#var ignore_behaviour_roll: bool = Random.rollFloat(IGNORE_BEHAVIOUR_CHANCE) if is_first_ai_turn else BehaviourCard.ai_datastore.last_ignore_behaviour_roll
	var ignore_behaviour_roll: bool = false # For now
	BehaviourCard.ai_datastore.last_ignore_behaviour_roll = ignore_behaviour_roll
	
	if !ignore_behaviour_roll:
		var is_in_combat: bool = !enemies.is_empty()
		var behaviours: Array = getBehaviours(BehaviourCard)
		behaviours = behaviours.filter(func(x: Behaviour): return (x.isCombatBehaviour() and is_in_combat) or (x.isOutOfCombatBehaviour() and !is_in_combat))
		
		var behaviour_amount: float = behaviours.size() + 1.0
		for behaviour in behaviours:
			var behaviour_tiles_to_value: Dictionary
			if is_in_combat: # For debugging
				behaviour_tiles_to_value = behaviour.getCombatTiles(BehaviourCard, tiles, enemies, allies)
			else:
				behaviour_tiles_to_value = behaviour.getOutOfCombatTiles(BehaviourCard, tiles, allies, enemies)
			
			for Tile: TileGD in behaviour_tiles_to_value:
				tiles_to_value[Tile] += behaviour_tiles_to_value[Tile]
				
		for Tile: TileGD in tiles_to_value:
			tiles_to_value[Tile] /= behaviour_amount
	return tiles_to_value

func getBehaviours(BehaviourCard: CardGD) -> Array:
	var archetype: ArchetypeInfo
	if BehaviourCard.ai_datastore.isReceiver():
		archetype = load(RECEIVER_ARCHETYPE_PATH)
	elif BehaviourCard.isAlly(1) and Game.getLevel().isAIAdventurerArchetypeGlobal(): archetype = load(ADVENTURER_ARCHETYPE_PATH)
	elif Game.getAllyUnits(1).all(func(x: CardGD): return x is not EpicCardGD and x.info.archetype.id == 1): archetype = load(BRUTE_ARCHETYPE_PATH)
	else: archetype = Card.getArchetypeFromInfo()
	return archetype.behaviours.map(func(x: GDScript): var behaviour := Behaviour.new(); behaviour.set_script(x); return behaviour)

func onCheckCallForHelp(allies: Array, enemies: Array) -> void:
	if !Card.ai_datastore.onCanCall(): return
	if !Card.isInCombat(): return
	if !Random.rollFloat(Card.getArchetypeFromInfo().calling_chance / 100.0): return
	
	var enemies_to_tiles: Dictionary = {}
	for EnemyCard in enemies:
		enemies_to_tiles[EnemyCard] = EnemyCard.getTile()
		
	Card.ai_datastore.onCall() # Sets call cooldown
	var available_allies: Array =  allies.filter(func(x: CardGD): return !x.ai_datastore.isReceiver() and\
	x.ai_datastore.onCanReceive() and !x.isInCombat()\
	and Random.rollFloat(x.getArchetypeFromInfo().accepting_chance / 100.0))
	for AllyCard in available_allies:
		AllyCard.ai_datastore.setIsReceiver(true, enemies_to_tiles)
	
func setIsEndUseTypeBoss(state: bool) -> void:
	is_end_use_type_boss = state
