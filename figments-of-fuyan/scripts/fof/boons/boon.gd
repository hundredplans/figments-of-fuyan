class_name BoonGD extends FofGD

signal update_ascend

var ascended: bool
var ability_save: Dictionary

func onFofInit() -> void:
	onResetCharges()

func onLoadData(data: SavedData) -> void:
	super(data)
	add_to_group("BoonsGD")
	ascended = data.ascended
	ability_save = data.ability_save
	
	for custom_variable in ability_save:
		set(custom_variable, ability_save[custom_variable])
	
func getAscended() -> bool:
	return ascended
	
func onSave() -> SavedDataBoon:
	return SavedDataBoon.new(info.id, false, public_id, ascended, ability_save)

func getIcon() -> Texture2D:
	return info.icon

func getDescription() -> String:
	return info.description if !ascended else info.ascended_description	
	
func onBoonAdded() -> void:
	onResetCharges()
	
	if Game.isLevel():
		onLevelStarted()

func getDisabled() -> bool:
	return false
	
func getCharges() -> int:
	return -1
	
func onResetCharges() -> void:
	pass

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
	onResetCharges()
	
func onProcessAction(action: Action) -> void:
	if action.post:
		if action is StartGameAction:
			onLevelStarted()
		elif action is ChangePhaseAction and action.phase in Game.ADVANCE_PHASES:
			onAdvanceTurn(Game.ADVANCE_PHASES.find(action.phase))
			
func onLevelStarted() -> void: pass # Called when the level literally starts
func onAdvanceTurn(_team: int) -> void: pass
