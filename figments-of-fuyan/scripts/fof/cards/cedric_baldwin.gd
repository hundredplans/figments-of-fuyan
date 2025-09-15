extends CardGD

const ABILITY_DELAY: float = 2.0

const TIER_ONE_ATTACK: int = 1
const TIER_TWO_ATTACK: int = 2
const TIER_THREE_ATTACK: int = 2
const TIER_FOUR_ATTACK: int = 2

const TIER_ONE_TURNS: int = 1
const TIER_TWO_TURNS: int = 1
const TIER_THREE_TURNS: int = 2
const TIER_FOUR_TURNS: int = 2

func onProcessAction(action: Action) -> void:
	super(action)
	
func getDescription(use_default_values: bool = false) -> String:
	if !use_default_values:
		return Helper.getDescription(super(), [active_effect_charges])
	return super(true)

func getActiveEffectTiles() -> ActiveEffectTiles:
	var adjacent_tiles: Array = Game.getAdjacentTiles(Tile, 1)
	var tiles: Array = adjacent_tiles.filter(func(x: TileGD): return Game.getAllyFieldCard(x, team) != null)
	return ActiveEffectTiles.new(adjacent_tiles, tiles)

func onActiveEffectPre(PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles) -> void:
	onForceAction(ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, PickedTile)))

func onActiveEffect(PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	var Card: CardGD = Game.getFieldCard(PickedTile)
	var attack_value: int = getTierAttack()
	var animation_action := AnimationAction.new(self, "Ability")
	animation_action.setActionDelay(ABILITY_DELAY)
	
	var camera_change_to_them_action := CameraChangeAction.new(Card)
	camera_change_to_them_action.setActionDelay(1.0)
	
	var actions: Array = [animation_action, StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, attack_value, getTierTurns())),\
		camera_change_to_them_action, CameraChangeAction.new(self)]
	onPushAction(actions)

func onAIAbilityChecker(active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic, type := Game.AbilityAI.NULL) -> TileGD:
	var ally_vision: Array = Game.getTeamVision(0)
	var tiles: Array = active_effect_tiles.pickable_tiles.filter(func(x: TileGD): return x in ally_vision)
	if !tiles.is_empty():
		#var enemies: Array = Game.getEnemyUnits(team)
		#var allies: Array = Game.getAllyUnits(team).filter(func(x: CardGD): return x.getTile() in tiles)
		#allies = allies.filter(func(x: CardGD):\
			#return enemies.any(func(y: CardGD):\
				#return Game.getCoordsDistance(x.getCoords(), y.getCoords()) <= x.getAttackRange() + x.speed))
		#
		#for AllyCard: CardGD in allies:
			#var get_damage_action := GetDamageAction.new(AllyCard,)
			#onForceAction(GetDamageAction.new())
		#
		#for AllyCard: CardGD in allies:
			#if 
		#if enemies.any(func(x: CardGD): return Game.getCoordsDistance(x.getCoords(), getCoords()) <= )
		return tiles.pick_random()
	return null
	
func getTierAttack() -> int:
	match tier:
		1: return TIER_ONE_ATTACK
		2: return TIER_TWO_ATTACK
		3: return TIER_THREE_ATTACK
		4: return TIER_FOUR_ATTACK
	return 0

func getTierTurns() -> int:
	match tier:
		1: return TIER_ONE_TURNS
		2: return TIER_TWO_TURNS
		3: return TIER_THREE_TURNS
		4: return TIER_FOUR_TURNS
	return 0
