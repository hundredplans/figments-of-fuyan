extends CardGD

const ABILITY_DELAY: float = 2.5
const AI_ABILITY_COOLDOWN: int = 2
var ai_ability_cooldown_turns_left: int
var remove_armor_next_turn: bool = false
var armor_id: int

const TIER_ONE_ARMOR_AMOUNT: int = 1
const TIER_TWO_ARMOR_AMOUNT: int = 1
const TIER_THREE_ARMOR_AMOUNT: int = 1
const TIER_FOUR_ARMOR_AMOUNT: int = 2

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is ChangePhaseAction and Game.isAdvanceTurn(action.phase, team) and armor_id > 0:
			onPushAction(RemoveOverworldTraitAction.new(self, armor_id, OverworldTrait.AddedBy.CRAB))
			armor_id = 0

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect.name == "Hardened Shell":
		return ActiveEffectTiles.new([Tile], [Tile])
	return null
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect.name == "Hardened Shell":
		var trait_data := SavedDataTrait.new(1, true, 0, getTierArmor())
		armor_id = 1
		ai_ability_cooldown_turns_left = AI_ABILITY_COOLDOWN
		
		var actions: Array = []
		var animation_action := AnimationAction.new(self, "Ability")
		animation_action.setActionDelay(ABILITY_DELAY)
		var overworld_trait_action := AddOverworldTraitAction.new(self, OverworldTrait.new(trait_data, OverworldTrait.AddedBy.CRAB, true), true)
		
		onPushAction([animation_action, overworld_trait_action])

# Use ability if enemies are within DISTANCE tiles below
const HARDENED_SHELL_ENEMY_DISTANCE_TO_USE: int = 4
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic) -> TileGD:
	var enemies: Array = getVisibleFieldCardsEnemies()
	var use_ability: bool = !enemies.is_empty() and ai_ability_cooldown_turns_left == 0 and\
	enemies.any(func(x: CardGD): return Game.getCoordsDistance(x.getCoords(), getCoords()) <= HARDENED_SHELL_ENEMY_DISTANCE_TO_USE)
	
	return active_effect_tiles.pickable_tiles[0] if use_ability else null

func onSave() -> SavedDataCard:
	ability_save['armor_id'] = armor_id
	ability_save['ai_ability_cooldown_turns_left'] = ai_ability_cooldown_turns_left
	return super()
	
func onCardTurnPassed(Card: CardGD) -> void:
	super(Card)
	if self != Card: return
	
	ai_ability_cooldown_turns_left = max(ai_ability_cooldown_turns_left - 1, 0)

func getTierArmor() -> int:
	match tier:
		1: return TIER_ONE_ARMOR_AMOUNT
		2: return TIER_TWO_ARMOR_AMOUNT
		3: return TIER_THREE_ARMOR_AMOUNT
		4: return TIER_FOUR_ARMOR_AMOUNT
	return 0
