class_name DefaultFightLogic extends Behaviour

func getTilesDFL(Card: CardGD, tiles: Array, attackables: Array, _allies: Array) -> DFLData:
	var KillTile: TileGD = getKillTile(Card, tiles, attackables)
	if KillTile != null:
		return DFLData.new({}, KillTile)
	var tiles_to_value: Dictionary = {}
	for Tile in tiles:
		tiles_to_value[Tile] = 1.0
	return DFLData.new(tiles_to_value, null)

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
