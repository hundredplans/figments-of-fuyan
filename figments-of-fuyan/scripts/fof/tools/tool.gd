class_name ToolGD extends FofGD

var Card: CardGD
var charges: int
var ability_save: Dictionary
var tier: int

var active_effect_charges: int
var active_effect_used: bool

@warning_ignore("unused_signal")
signal update_active_effect_description
signal update_tier

func onFofInit() -> void:
	onRegularReset()

func onLoadData(data: SavedData) -> void:
	active_effect_charges = data.active_effect_charges
	active_effect_used = data.active_effect_used
	tier = data.tier
		
	for custom_variable in ability_save:
		set(custom_variable, ability_save[custom_variable])
	
func getDuplicateData() -> SavedDataTool:
	var data := onSave()
	var dupe_data: SavedDataTool = data.duplicate()
	dupe_data.public_id = 0
	return dupe_data
	
func onAdvanceTurn() -> void:
	var actions: Array = [ChangeActiveEffectUsedAction.new(self, false)]
	onPushAction(actions)
	
func onSave() -> SavedDataTool:
	return SavedDataTool.new(info.id, false, public_id, active_effect_charges, charges, ability_save, tier, active_effect_used)

func getRarity() -> Game.Rarities:
	return info.rarity

func getIcon() -> Texture2D:
	return info.icon
	
func getTier() -> int:
	return tier

func getDescription(use_default_values: bool = false) -> String:
	return info.getDescription(tier, use_default_values)

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is AwakenAction and action.Card == Card:
			onToolHolderAwakened()
		elif action is DeathAction and action.Defender == Card:
			onToolHolderDeath()
		elif action is EndGameAction:
			onReset()
			
func onToolEquipped() -> void:
	if Card.is_in_group("FieldCardsGD"): onToolHolderAwakened()
	if info.auto_reset_charges:
		onResetCharges()
	
func onToolHolderAwakened() -> void:
	pass
	
func onToolHolderDeath() -> void:
	pass
	
func onReset(override: bool = false) -> void:
	if info.rarity == Game.Rarities.MINI:
		onPushAction(RemoveToolAction.new(Card))
	
	if !override: return
	active_effect_used = false
	active_effect_charges = getDefaultActiveEffectCharges()
	
func onRegularReset() -> void: #  Fof Init, Awakened, Death, Level Start, Level End
	if info.auto_reset_charges:
		onResetCharges()
	
func onCardTurnPassed() -> void:
	pass
	
func onToolUnequippedDefault(keep_tool: bool) -> void:
	onToolUnequipped()
	if Card.is_in_group("FieldCardsGD"): onToolHolderDeath()
	if !keep_tool:
		onClear()
	
func onToolUnequipped() -> void:
	pass
	
func isLevelVisible() -> bool:
	return Card.isLevelVisible()

func onLevelEnded(_win: bool) -> void:
	pass
		
#region Charges
func getDefaultCharges() -> int:
	return 0
	
func onResetCharges() -> void:
	if !info.use_charges: return
	
	var delta: int = -charges if !info.reset_to_default else (getDefaultCharges() - charges)
	var infinite: bool = info.reset_to_default and getDefaultCharges() == -1
	onForceAction(ChangeToolChargesAction.new(self, delta, infinite))
	
func onChangeCharges(delta: int, infinite: bool) -> void:
	if !infinite: charges = max(charges + delta, 0) 
	else: charges = -1
#endregion

func onRetiered(_tier: int) -> void:
	tier = _tier
	var tier_datastore: ToolTierDatastore = info.getTierDatastore(tier)
	var actions: Array = []
	onPushAction(actions)
	update_tier.emit(tier)
	
func getToolTierDatastore(_tier: int = tier) -> ToolTierDatastore:
	return info.getTierDatastore(_tier)

func getCard() -> CardGD:
	return Card

func onCreateTbcUI(parent: Control, hoverable: bool = false, draggable: bool = false, autoscale: bool = false) -> TbcUI:
	var tbc: TbcUI = load(info.TOOL_ICON_PATH).instantiate()
	parent.add_child(tbc)
	tbc.setInfo(self, hoverable, autoscale)
	tbc.setDraggable(draggable)
	return tbc

#region Active Effects
func onActiveEffect(_PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles) -> void: pass
func onActiveEffectPre(_PickedTile: TileGD, _active_effect_tiles: ActiveEffectTiles) -> void: pass
func getActiveEffectTiles() -> ActiveEffectTiles: return null

func isValidActiveEffect() -> bool: # Can show up
	return active_effect_charges != -2
	
func isActiveEffectDisabled() -> bool: # Is greyedo ut
	return active_effect_charges == 0 or Card.getTurnState() == Game.TurnStates.PASSED or active_effect_used
	
func onAIActiveEffectChecker(_active_effect_tiles: ActiveEffectTiles, _dfl: DefaultFightLogic, type := Game.AbilityAI.NULL) -> TileGD:
	return null
	
func onAIActiveEffectCheckerDefault() -> ActiveEffectTiles:
	if isActiveEffectDisabled(): return null
	
	var active_effect_tiles: ActiveEffectTiles = getActiveEffectTiles()
	if active_effect_tiles == null or active_effect_tiles.pickable_tiles.is_empty(): return null
	return active_effect_tiles
	
func setActiveEffectUsed(state: bool) -> void: active_effect_used = state
func getActiveEffectUsed() -> bool: return active_effect_used
func getActiveEffectCharges() -> int: return active_effect_charges
func setActiveEffectCharges(value: int) -> void: active_effect_charges = value
func getDefaultActiveEffectCharges() -> int: return -1
#endregion
