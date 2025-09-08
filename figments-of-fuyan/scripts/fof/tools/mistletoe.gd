extends ToolGD

var combinations: Array = [
	[Game.Stats.MAX_HEALTH, Game.Stats.MAX_SPEED, Game.Stats.ATTACK],
	[Game.Stats.MAX_HEALTH, Game.Stats.ATTACK, Game.Stats.MAX_SPEED],
	[Game.Stats.ATTACK, Game.Stats.MAX_SPEED, Game.Stats.MAX_HEALTH],
	[Game.Stats.MAX_SPEED, Game.Stats.ATTACK, Game.Stats.MAX_HEALTH],
	[Game.Stats.MAX_SPEED, Game.Stats.MAX_HEALTH, Game.Stats.SPEED]]
	
func onToolHolderAwakened() -> void:
	super()
	onPushAction(getStatAction())
	
func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect.name == "Mistletoe":
		return ActiveEffectTiles.new([Card.getTile()], [Card.getTile()])
	return null
	
func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect.name == "Mistletoe":
		onPushAction(getStatAction())
	
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, active_effect_tiles: ActiveEffectTiles, _DFL: DefaultFightLogic, type := Game.AbilityAI.NULL) -> TileGD:
	return active_effect_tiles.pickable_tiles[0]
	
func getStatAction() -> StatAction:
	var combination: Array = getRandomCombination()
	var values: Array = [Card.getAttack(), Card.getHealth(), Card.getMaxSpeed()]
	var types: Array = [Game.Stats.ATTACK, Game.Stats.MAX_HEALTH, Game.Stats.MAX_SPEED]
	var new_types: Array = []
	var new_values: Array = []
	
	for i in range(combination.size()):
		var new_type: Game.Stats = combination[i]
		var new_value: int = values[i]
		
		if values[i] == 0 and new_type == Game.Stats.MAX_HEALTH: # Rerolls
			return getStatAction()
			
		new_values.append(new_value)
		new_types.append(new_type)
		if new_type == Game.Stats.MAX_HEALTH:
			new_values.append(new_value)
			new_types.append(Game.Stats.HEALTH)
			
	return StatAction.new(StatInfo.new(Card, new_types, new_values, 0, true, true, true))
	
func getRandomCombination() -> Array:
	return combinations.pick_random()

func getDescription(use_default_values: bool = false) -> String:
	var active_effect: ActiveEffectDatastore = getActiveEffectByName("Mistletoe")
	if !use_default_values and active_effect != null:
		return Helper.getDescription(super(), [active_effect.charges])
	return super(true)
