class_name BoonGD extends FofGD

signal update_ascend

var ascended: bool
var ability_save: Dictionary
var charges: int
var tier: int

func onFofInit() -> void:
	onResetCharges()

func onLoadData(data: SavedData) -> void:
	super(data)
	add_to_group("BoonsGD")
	ascended = data.ascended
	ability_save = data.ability_save
	charges = data.charges
	tier = data.tier
	
	for custom_variable in ability_save:
		set(custom_variable, ability_save[custom_variable])
	
func getAscended() -> bool:
	return ascended
	
func onSave() -> SavedDataBoon:
	return SavedDataBoon.new(info.id, false, public_id, ascended, charges, ability_save, tier)

func getIcon() -> Texture2D:
	return info.icon

func getDescription(use_default_values: bool = false) -> String:
	return info.getDescription(tier, use_default_values)
	
func getTier() -> int:
	return tier
func onBoonAdded() -> void:
	onResetCharges()
	
	if Game.isLevel():
		onLevelStarted()

func getDisabled() -> bool:
	return false
	
func getCharges() -> int:
	return charges
	
func onResetCharges() -> void:
	if !info.use_charges: return
	
	var delta: int = -charges if !info.reset_to_default else (getDefaultCharges() - charges)
	onForceAction(ChangeBoonChargesAction.new(self, delta))
		
func getDefaultCharges() -> int:
	return 0

func onAscend(state: bool) -> void:
	ascended = state
	update_ascend.emit(state)
	
func isAddRequirementMet() -> bool: # Whether you can add this to your boons
	return true

func onLevelEnded(_win: bool) -> void:
	if info.elite_fight_curse or info.rarity == Game.Rarities.MINI:
		onPushAction(RemoveBoonAction.new(info.id))
		onClear()
		return
		
	if info.auto_reset_charges:
		onResetCharges()
	
func onProcessAction(action: Action) -> void:
	if action.post:
		if action is StartGameAction:
			onLevelStarted()
		elif action is ChangePhaseAction and action.phase in Game.ADVANCE_PHASES:
			onAdvanceTurn(Game.ADVANCE_PHASES.find(action.phase))
			
		elif action is ChangeTurnStateAction and action.turn_state == Game.TurnStates.PASSED:
			onCardTurnPassed(action.Card)
			
func onLevelStarted() -> void: # Called when the level literally starts
	if info.auto_reset_charges:
		onResetCharges()
		
func onAdvanceTurn(_team: int) -> void: pass
func onCardTurnPassed(_Card: CardGD) -> void: pass
func onRemoveBoon() -> void: pass

func onChangeCharges(delta: int) -> void:
	charges = max(charges + delta, 0) 
