class_name ToolGD extends FofGD

var Card: CardGD
var charges: int
var ascended: bool
var active_effects: Array[ActiveEffectDatastore]
var ability_save: Dictionary

@warning_ignore("unused_signal")
signal update_active_effect_description

func onLoadData(data: SavedData) -> void:
	ascended = data.ascended
	active_effects = data.active_effects
	
	for active_effect in active_effects:
		active_effect.owner = self
		
	for custom_variable in ability_save:
		set(custom_variable, ability_save[custom_variable])
	
func onSave() -> SavedDataTool:
	return SavedDataTool.new(info.id, false, public_id, ascended, active_effects, charges, ability_save)
	
func getAscended() -> bool:
	return ascended
	
func onCreateActiveEffects() -> void:
	active_effects = []
	onPushAction(info.active_abilities.map(func(x: ActiveEffectDatastore): return AddActiveEffectAction.new(self, x.duplicate())))

func onAddActiveEffect(active_effect: ActiveEffectDatastore) -> void:
	active_effects.append(active_effect)
	
func getActiveEffects() -> Array:
	return active_effects
	
func onAIAbilityChecker(_active_effect: ActiveEffectDatastore, _active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic) -> TileGD:
	return null
	
func onAIAbilityCheckerDefault(active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	if active_effect.getDefaultDisabled(Card): return null
	
	var active_effect_tiles: ActiveEffectTiles = getActiveEffectTiles(active_effect)
	if active_effect_tiles == null or active_effect_tiles.pickable_tiles.is_empty(): return null
	return active_effect_tiles

func getRarity() -> Game.Rarities:
	return info.rarity

func getIcon() -> Texture2D:
	return info.icon

func getDescription() -> String:
	return info.description if !ascended else info.ascended_description	

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is AwakenAction and action.Card == Card:
			onToolHolderAwakened()
		elif action is DeathAction and action.Defender == Card:
			onToolHolderDeath()
		elif action is EndGameAction:
			onReset()
		elif action is AscendToolAction:
			onToolAscended(action.state)

func onToolAscended(_state: bool) -> void:
	pass

func getActiveEffectTiles(_active_effect: ActiveEffectDatastore) -> ActiveEffectTiles:
	return null
	
func onActiveEffect(_active_effect: ActiveEffectDatastore, _PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles) -> void:
	pass
	
func onActiveEffectPre(_active_effect: ActiveEffectDatastore, _PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles) -> void:
	pass
	
func getActiveEffectDisabled(_active_effect: ActiveEffectDatastore) -> bool:
	return false
	
func setActiveEffectUsed(active_effect: ActiveEffectDatastore, used: bool) -> void:
	active_effect.used = used
	
func getActiveEffectDescription(_active_effect: ActiveEffectDatastore, description: String) -> String:
	return description
	
func onToolEquipped() -> void:
	if Card.is_in_group("FieldCardsGD"): onToolHolderAwakened()
	if info.auto_reset_charges:
		onResetCharges()
	
func onToolHolderAwakened() -> void:
	onCreateActiveEffects()
	
func onToolHolderDeath() -> void:
	pass
	
func onReset(_override: bool = false) -> void:
	if info.rarity == Game.Rarities.MINI:
		onPushAction(RemoveToolAction.new(Card))
	
func onRegularReset() -> void: #  Fof Init, Awakened, Death, Level Start, Level End
	if info.auto_reset_charges:
		onResetCharges()
	
func onCardTurnPassed() -> void:
	pass
	
func onToolUnequipped() -> void:
	if Card.is_in_group("FieldCardsGD"): onToolHolderDeath()
	onClear()
	
func isLevelVisible() -> bool:
	return Card.isLevelVisible()
	
func setAscended(state: bool) -> void:
	ascended = state

func onLevelEnded(_win: bool) -> void:
	pass
		
#region Charges
func getDefaultCharges() -> int:
	return 0
	
func onResetCharges() -> void:
	if !info.use_charges: return
	
	var delta: int = -charges if !info.reset_to_default else (getDefaultCharges() - charges)
	onForceAction(ChangeToolChargesAction.new(self, delta))
	
func onChangeCharges(delta: int) -> void:
	charges = max(charges + delta, 0) 
#endregion
