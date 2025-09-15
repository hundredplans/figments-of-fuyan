extends ToolGD

const TIER_TO_REMOVE_ATTACK_RESTRICTION: int = 4
const DISARM_BASE_ATTACK: int = 2
func onProcessAction(action: Action) -> void:
	super(action)

func getActiveEffectTiles() -> ActiveEffectTiles:
	var in_range_tiles: Array = Game.getAdjacentTiles(Card.Tile)
	var available_enemies: Array = in_range_tiles.map(func(x: TileGD): return Game.getEnemyFieldCard(x, Card.team)).filter(func(y: CardGD): return y != null)
	
	if tier < TIER_TO_REMOVE_ATTACK_RESTRICTION:
		var attack_minimum: int = DISARM_BASE_ATTACK + (tier - 1)
		available_enemies = available_enemies.filter(func(x: CardGD): return x.getAttack() <= attack_minimum)
	return ActiveEffectTiles.new(in_range_tiles, in_range_tiles.filter(func(x: TileGD): return Game.getEnemyFieldCard(x, Card.team) != null))
	
func onActiveEffect(PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	var EnemyCard: CardGD = Game.getFieldCard(PickedTile)
	EnemyCard.onCreateBaseStatusEffect(4)
	
	var actions: Array = [
		ChangeTileRotationAction.new(Card, Game.getRelativeTileRotation(Card.Tile, EnemyCard.Tile)),
		ChangeTileRotationAction.new(EnemyCard, Game.getRelativeTileRotation(EnemyCard.Tile, Card.Tile))]
	onPushAction(actions)

# If attacking someone with a non-lethal attack
func onAIAbilityChecker(active_effect_tiles: ActiveEffectTiles, DFL: DefaultFightLogic, type := Game.AbilityAI.NULL) -> TileGD:
	if DFL.getIsCardAttack() and DFL.getKillPath().is_empty():
		return active_effect_tiles.pickable_tiles.pick_random()
	return null

func getDescription(use_default_values: bool = false) -> String:
	if !use_default_values:
		return Helper.getDescription(super(), [active_effect_charges])
	return super(true)
