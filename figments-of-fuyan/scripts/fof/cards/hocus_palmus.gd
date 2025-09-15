extends CardGD

const FIRST_HAT_DELAY: float = 1.5
const SECOND_HAT_DELAY: float = 1.5
const SECOND_HAT_AFTER_DELAY: float = 1.0

const ABILITY_DELAY: float = 2.2
const SPECTATE_TELEPORTED_UNIT_DELAY: float = 1.5
const HAT_ID: int = 1

const TIER_ONE_HEAL: int = 2
const TIER_TWO_HEAL: int = 2
const TIER_THREE_HEAL: int = 3
const TIER_FOUR_HEAL: int = 99

const TIER_ONE_AMOUNT: int = 1
const TIER_TWO_AMOUNT: int = 2
const TIER_THREE_AMOUNT: int = 3
const TIER_FOUR_AMOUNT: int = 3

func isActiveEffectDisabled() -> bool:
	return super() or !isSpawnAvailable()

func getActiveEffectTiles() -> ActiveEffectTiles:
	return ActiveEffectTiles.new([getTile()], [getTile()])
	
func onActiveEffectPre(_PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles) -> void: pass
	
func onActiveEffect(PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	var allies: Array = getHealableAllies()
	
	var animation_action := AnimationAction.new(self, "Ability")
	animation_action.setActionDelay(ABILITY_DELAY)
	
	var heal_amount: int = getTierHeal()
	var actions: Array = [animation_action]
	var used_spawn_tiles: Array = []
	for AllyCard: CardGD in allies:
		var SpawnTile: TileGD = getRandomSpawnTile(used_spawn_tiles)
		if SpawnTile == null: continue
		used_spawn_tiles.append(SpawnTile)
		
		var FirstHat: VFXGD = SavedData.onLoadModel(SavedDataVFX.new(HAT_ID, true), AllyCard)
		FirstHat.setStartHat(true)
		
		var SecondHat: VFXGD = SavedData.onLoadModel(SavedDataVFX.new(HAT_ID, true), AllyCard)
		SecondHat.setStartHat(false)
		
		var first_hat_action := CreateVFXAction.new(FirstHat, true)
		first_hat_action.setActionDelay(FIRST_HAT_DELAY)
		
		var second_hat_action := CreateVFXAction.new(SecondHat, true)
		second_hat_action.setActionDelay(SECOND_HAT_DELAY)
		
		var after_camera_action := CameraChangeAction.new(AllyCard)
		after_camera_action.setActionDelay(SECOND_HAT_AFTER_DELAY)
		
		actions += [CameraChangeAction.new(AllyCard), first_hat_action, OccupyAction.new(AllyCard, SpawnTile),\
			DestroyVFXAction.new(FirstHat), HealAction.new(HealDatastore.new(AllyCard, heal_amount)), second_hat_action, after_camera_action]
	
	actions.append(CameraChangeAction.new(self))
	onPushAction(actions)
		
func getHealableAllies() -> Array:
	var allies: Array = Game.getAllyUnits(team)
	allies.erase(self)
	allies = allies.filter(func(x: CardGD): return x.isHealable())
	allies.shuffle()
	allies.sort_custom(func(x: CardGD, y: CardGD): return x.getMaxHealth() - x.getHealth() > y.getMaxHealth() - y.getHealth())
	allies.resize(getTierAmount())
	allies = allies.filter(func(x: CardGD): return x != null)
	return allies
		
# Escapes injured units in combat, sorts by energy
func onAIAbilityChecker(active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic, type := Game.AbilityAI.NULL	) -> TileGD:
	if Game.getAllyUnits(team).filter(func(x: CardGD): return x.isHealable()).size() >= getTierAmount():
		return getTile()
	return null
	#var cards: Array = active_effect_tiles.pickable_tiles.map(func(x: TileGD): return Game.getFieldCard(x))
	#cards = cards.filter(func(x: CardGD): return x.isInCombat() and x.getArchetypeEnum() not in [Game.Archetypes.WARDEN, Game.Archetypes.BRUTE])
	#cards.sort_custom(func(x: CardGD, y: CardGD): return x.energy > y.energy)
	#return cards[0].getTile() if !cards.is_empty() else null
		
func isSpawnAvailable() -> bool:
	var team_spawn: String = "Ally" if team == 0 else ("Enemy" if team == 1 else "Neutral")
	return get_tree().get_nodes_in_group(team_spawn + "SpawnsGD").any(func(x: SpawnGD): return !x.isSpawnOccupied())

func getRandomSpawnTile(used_spawn_tiles: Array = []) -> TileGD:
	var team_spawn: String = "Ally" if team == 0 else ("Enemy" if team == 1 else "Neutral")
	return get_tree().get_nodes_in_group(team_spawn + "SpawnsGD")\
		.filter(func(x: SpawnGD): return !x.isSpawnOccupied() and x.getTile() not in used_spawn_tiles)\
		.map(func(x: SpawnGD): return x.getTile())\
		.pick_random()
	
func getDescription(use_default_values: bool = false) -> String:
	if !use_default_values:
		return Helper.getDescription(super(), [active_effect_charges])
	return super(true)

func getTierHeal() -> int:
	match tier:
		1: return TIER_ONE_HEAL
		2: return TIER_TWO_HEAL
		3: return TIER_THREE_HEAL
		4: return TIER_FOUR_HEAL
	return 0

func getTierAmount() -> int:
	match tier:
		1: return TIER_ONE_AMOUNT
		2: return TIER_TWO_AMOUNT
		3: return TIER_THREE_AMOUNT
		4: return TIER_FOUR_AMOUNT
	return 0
