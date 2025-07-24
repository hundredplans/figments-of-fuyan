extends CardGD

const ABILITY_DELAY: float = 2.0
func onProcessAction(action: Action) -> void:
	super(action)

func getActiveEffectTiles(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	super(active_effect)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "For Varoma!":
		var pickable_tiles: Array = getVisibleFieldCardsAllies().map(func(x: CardGD): return x.getTile())
		var tiles: Array = getVisibleTiles()
		tiles.erase(Tile)
		return ActiveEffectTiles.new(tiles, pickable_tiles)
	return null

func onActiveEffectPre(_active_effect: ActiveEffectDatastore, PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles) -> void:
	onForceAction(ChangeTileRotationAction.new(self, Game.getRelativeTileRotation(Tile, PickedTile)))

func onActiveEffect(active_effect: ActiveEffectDatastore, PickedTile: TileGD, active_effect_tiles: ActiveEffectTiles) -> void:
	super(active_effect, PickedTile, active_effect_tiles)
	if active_effect is ActiveAbilityDatastore and active_effect.name == "For Varoma!":
		var Card: CardGD = Game.getFieldCard(PickedTile)
		var attack_value: int = 1
		var animation_action := AnimationAction.new(self, "Ability")
		animation_action.setActionDelay(ABILITY_DELAY)
		
		var camera_change_to_them_action := CameraChangeAction.new(Card)
		camera_change_to_them_action.setActionDelay(1.0)
		
		var actions: Array = [animation_action, StatAction.new(StatInfo.new(Card, Game.Stats.ATTACK, attack_value, 1)),\
			camera_change_to_them_action, CameraChangeAction.new(self)]
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
	var active_effect: ActiveEffectDatastore = getActiveEffectByName("For Varoma!")
	if !use_default_values and active_effect != null:
		return Helper.getDescription(super(), [active_effect.charges])
	return super(true)
