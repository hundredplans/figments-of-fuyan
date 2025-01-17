class_name DefaultFightLogic extends Behaviour

const FALL_DAMAGE_DEATH_DECENTIVIZATION: float = -10.0

func getTilesDFL(Card: CardGD, tiles: Array, attackables: Array, allies: Array) -> DFLData:
	var KillTile: TileGD = getKillTile(Card, tiles, attackables)
	if KillTile != null:
		return DFLData.new({}, KillTile)
		
	var in_player_vision: bool = attackables.any(func(x: CardGD): return x.isAlly(0))
	var tiles_to_value: Dictionary = {}
	
	for Tile in tiles:
		tiles_to_value[Tile] = getFallDamageTileValue(Card, Tile) # 1 by default
	
	
	if !attackables.is_empty():
		pass
	
	Card.onUnitSpecificTransforms(tiles_to_value, attackables, allies)
	return DFLData.new(tiles_to_value, null)
	
func getFallDamageTileValue(Card: CardGD, Tile: TileGD) -> float:
	var accum_value: float = 0.0
	var total_damage: int = 0
	for MovementPathTile in Tile.getMovementPathTiles():
		var fall_damage: int = Tile.getFallDamage(MovementPathTile)
		total_damage += fall_damage
	
	if !Card.isCardSurviveFallDamage(total_damage):
		return FALL_DAMAGE_DEATH_DECENTIVIZATION
	elif total_damage > 0:
		return 0.5
	return 1.0

func getKillTile(Card: CardGD, tiles: Array, attackables: Array) -> TileGD:
	attackables = attackables.duplicate()
	attackables = attackables.filter(func(x: CardGD): return Card.isGameObjectAttackable(x, x.Tile))
	attackables = attackables.filter(isAttackableKillable.bind(Card))
	attackables.sort_custom(func(x: CardGD, y: CardGD): return x.energy > y.energy)
	attackables.shuffle()
	return attackables[0].Tile if !attackables.is_empty() else null
	
func isAttackableKillable(EnemyCard: CardGD, Card: CardGD) -> bool:
	var damage_action := GetDamageAction.new(Card, EnemyCard, Card.getAttackDamage())
	EnemyCard.onForceAction(damage_action)
	return damage_action.damage >= EnemyCard.health
