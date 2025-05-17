extends CardGD

var revenge_triggers: int
const ABILITY_DELAY: float = 2.0

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidRevenge(action):
		onPushAction(RevengeAction.new(self, action.owner))
		
func onRevenge(_action: DamageAction) -> void:
	revenge_triggers += 1

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Bloodclad Armor":
		return ActiveEffectTiles.new([getTile()], [getTile()])
	return null
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "Bloodclad Armor":
		var trait_data := SavedDataArmor.new(1, true, 0)
		trait_data.armor = 1
		
		var animation_action := AnimationAction.new(self, "Ability")
		animation_action.setActionDelay(ABILITY_DELAY)
		
		var actions: Array = [
			animation_action,
			AddOverworldTraitAction.new(self, OverworldTrait.new(trait_data, OverworldTrait.AddedBy.HAVEL_ROCKFOOT, true), true)]
			
		if revenge_triggers > 0:
			actions.append(StatAction.new(StatInfo.new(self, [Game.Stats.ATTACK, Game.Stats.HEALTH], [revenge_triggers, revenge_triggers])))
			revenge_triggers = 0
		
		onPushAction(actions)
		onAbility()

func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic) -> TileGD:
	var ally_vision: Array = Game.getTeamVision(0)
	var tiles: Array = active_effect_tiles.pickable_tiles.filter(func(x: TileGD): return x in ally_vision)
	if !tiles.is_empty() and revenge_triggers > 0:
		return tiles.pick_random()
	return null

func getActiveEffectDisabled(_active_effect: ActiveEffectDatastore) -> bool:
	return false

func getDescription() -> String:
	return super()

func onSave() -> SavedDataCard:
	ability_save['revenge_triggers'] = revenge_triggers
	return super()
	
func getDefaultCharges() -> int:
	return 0
	
func onRegularReset() -> void:
	super()
	revenge_triggers = getDefaultCharges()
