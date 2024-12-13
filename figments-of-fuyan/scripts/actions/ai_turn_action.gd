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

func _init(_Card: CardGD, _roll_for_ignore_behaviour: bool = false) -> void:
	super()
	Card = _Card
	roll_for_ignore_behaviour = _roll_for_ignore_behaviour
		
func onPostAction() -> void:
	var tiles: Array = Game.getsetMovementRange(Card)
	tiles.erase(Card.Tile)
	
	var attackables: Array = tiles.filter(func(x: TileGD): return Game.getFieldCard(x))
	var allies: Array = Card.getVisibleFieldCardsAllies()
	var enemies: Array = Card.getVisibleFieldCardsEnemies()
	
	var dfl_data: DFLData = onDefaultFightLogic(tiles, allies, enemies)
	if dfl_data.KillTile != null:
		onTileChosen(dfl_data.KillTile)
		return
	
	var tiles_to_value: Dictionary = dfl_data.tiles_to_value
	var ignore_behaviour_roll: bool = Random.rollFloat(IGNORE_BEHAVIOUR_CHANCE) if roll_for_ignore_behaviour else Card.last_ignore_behaviour_roll
	Card.last_ignore_behaviour_roll = ignore_behaviour_roll
	
	if !ignore_behaviour_roll:
		var behaviour_amount: int = Card.info.archetype.behaviours.size() + 1
		for behaviour_script in Card.info.archetype.behaviours:
			var behaviour := Behaviour.new()
			behaviour.script = behaviour_script
			var behaviour_tiles_to_value: Dictionary = \
				behaviour.getCombatTiles(Card, tiles, enemies) if !enemies.is_empty() else behaviour.getOutOfCombatTiles(Card, tiles, allies)
			
			for Tile in behaviour_tiles_to_value:
				tiles_to_value[Tile] += behaviour_tiles_to_value[Tile]
				
		for Tile in tiles_to_value:
			tiles_to_value[Tile] /= behaviour_amount
	
	var tiles_sorted_by_value: Array = tiles_to_value.keys()
	tiles_sorted_by_value.sort_custom(func(x: TileGD, y: TileGD): return tiles_to_value[x] > tiles_to_value[y])
	tiles_sorted_by_value.resize(TOP_AMOUNT)
	tiles_sorted_by_value = tiles_sorted_by_value.filter(func(x: TileGD): return x != null and tiles_to_value[x] >= 0)
	
	var index: int = min(Random.getRandomKeyVariant(TOP_ODDS), tiles_sorted_by_value.size() - 1)
	if index >= 0: # If the tile is valid
		onTileChosen(tiles_sorted_by_value[index])
		return
	onPushAction([ChangeTurnStateAction.new(Card, Game.TurnStates.ACTIVE), MovementFinishAction.new(Card, [])])

func getLogInfo() -> Array:
	return ["Card: " + Card.info.name]
	
func onDefaultFightLogic(tiles: Array, allies: Array, enemies: Array) -> DFLData:
	var DFL := DefaultFightLogic.new()
	return DFL.getTilesDFL(Card, tiles, enemies, allies)

func onTileChosen(Tile: TileGD) -> void:
	var actions: Array = [ChangeTurnStateAction.new(Card, Game.TurnStates.ACTIVE),
		MovementAction.new(Card, Tile.getMovementPathTiles())]
	onPushAction(actions)
