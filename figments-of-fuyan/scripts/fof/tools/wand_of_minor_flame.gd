extends ToolGD

const TIER_ONE_DAMAGE: int = 1
const TIER_TWO_DAMAGE: int = 1
const TIER_THREE_DAMAGE: int = 1
const TIER_FOUR_DAMAGE: int = 2

func getActiveEffectTiles() -> ActiveEffectTiles:
	var Tile: TileGD = Card.getTile()
	var team: int = Card.getTeam()
	var tiles: Array = Card.getVisibleTiles()
	return ActiveEffectTiles.new(tiles, tiles.filter(func(x: TileGD): return Game.getEnemyFieldCard(x, team) != null and x != Tile))

func onActiveEffect(PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	var EnemyCard: CardGD = Game.getFieldCard(PickedTile)
	onForceAction(ChangeTileRotationAction.new(Card, Game.getRelativeTileRotation(Card.getTile(), PickedTile)))
	onPushAction(DamageAction.new(Card, EnemyCard, getTierDamage(), Game.DamageTypes.OTHER))
		
func onAIAbilityChecker(active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic, type := Game.AbilityAI.NULL) -> TileGD:
	var enemies: Array = active_effect_tiles.pickable_tiles.map(func(x: TileGD): return Game.getFieldCard(x))
	var valid_enemies: Array = []
	for EnemyCard: CardGD in enemies:
		var get_damage_action := GetDamageAction.new(Card, EnemyCard, getTierDamage(), Game.DamageTypes.OTHER)
		onForceAction(get_damage_action)
		var damage: int = get_damage_action.getDamage()
		if damage >= EnemyCard.getHealth():
			valid_enemies.append(EnemyCard)
	
	if !valid_enemies.is_empty():
		valid_enemies.shuffle()
		valid_enemies.sort_custom(func(x: CardGD, y: CardGD): return x.getEnergy() > y.getEnergy())
		return valid_enemies[0].getTile()
	return null
	
func getDescription(use_default_values: bool = false) -> String:
	if !use_default_values:
		return Helper.getDescription(super(), [active_effect_charges])
	return super(true)
		
func getTierDamage() -> int:
	match tier:
		1: return TIER_ONE_DAMAGE
		2: return TIER_TWO_DAMAGE
		3: return TIER_THREE_DAMAGE
		4: return TIER_FOUR_DAMAGE
	return 0
	
