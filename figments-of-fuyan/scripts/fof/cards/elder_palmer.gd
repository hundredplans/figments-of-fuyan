extends CardGD

const GUARANTEED_HEAL_UNIT_AMOUNT_AI: int = 2
const SINGLE_UNIT_CHANCE: float = 0.1

const ARMOR_TRAIT_ID: int = 1
const DAZE_STATUS_EFFECT_ID: int = 4

const ABILITY_DELAY: float = 2.0
const CHANGE_BACK_DELAY: float = 2.0

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Palmist Prayer":
		var tiles: Array = getVisibleFieldCardsAllies().filter(func(x: CardGD): return x.isHealable())\
		.map(func(x: CardGD): return x.Tile)
		tiles.erase(Tile)
		return ActiveEffectTiles.new(tiles, tiles)
	return null
	
func onActiveEffectPre(_active_effect: ActiveEffectDatastore, PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles) -> void:
	onForceAction(ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, PickedTile)))
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Palmist Prayer":
		var Card: CardGD = Game.getFieldCard(PickedTile)
		var heal_amount: int = 1
		var armor_amount: int = 1 if tier == 1 else 2
		
		var animation_action := AnimationAction.new(self, "Ability")
		animation_action.setActionDelay(ABILITY_DELAY)
		
		var camera_change_action := CameraChangeAction.new(Card)
		var camera_change_back_action := CameraChangeAction.new(Game.getLevel().getSpectateObject())
		
		var armor_trait_data := SavedDataTrait.new(ARMOR_TRAIT_ID, true, 0, armor_amount)
		var armor_overworld := OverworldTrait.new(armor_trait_data, OverworldTrait.AddedBy.ELDER_PALMER, true, 1)

		var daze_action: AddStatusEffectAction = Card.onCreateBaseStatusEffectAction(DAZE_STATUS_EFFECT_ID, 1)
		daze_action.setActionDelay(CHANGE_BACK_DELAY)
		var actions: Array = [
			animation_action,
			camera_change_action,
			HealAction.new(HealDatastore.new(Card, heal_amount)),
			AddOverworldTraitAction.new(Card, armor_overworld, true),
			daze_action,
			camera_change_back_action]
		
		onPushAction(actions)

func getActiveEffectDisabled(_active_effect: ActiveEffectDatastore) -> bool:
	return false
	
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic) -> TileGD:
	var ally_vision: Array = Game.getTeamVision(0)
	var tiles: Array = active_effect_tiles.pickable_tiles.filter(func(x: TileGD): return x in ally_vision)
	if !tiles.is_empty():
		return tiles.pick_random()
	return null

func getDescription(use_default_values: bool = false) -> String:
	var active_effect: ActiveEffectDatastore = getActiveEffectByName("Palmist Prayer")
	if !use_default_values and active_effect != null:
		return Helper.getDescription(super(), [active_effect.charges])
	return super(true)
