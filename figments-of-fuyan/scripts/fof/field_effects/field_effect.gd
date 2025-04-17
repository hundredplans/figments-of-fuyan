class_name FieldEffectGD extends FofGD

signal update_charges

var Card: CardGD
var FofObject: FofGD # Equivalent to owner
var ability_save: Dictionary
var charges: int = -1
var turns: int = -1

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is ChangeTurnStateAction and action.turn_state == Game.TurnStates.PASSED and action.Card == Card:
			onCardTurnPassed()
			
		elif action is DeathAction and action.Defender == Card:
			onPushAction(RemoveFieldEffectAction.new(self))

func onCardTurnPassed() -> void:
	if turns > 0:
		turns = max(turns - 1, 0)
		if turns == 0: onPushAction(RemoveFieldEffectAction.new(self))

func getDescription() -> String:
	match info.ascended_type:
		FieldEffectInfo.AscendedTypes.CARD:
			if Card.ascended: return info.ascended_description
		FieldEffectInfo.AscendedTypes.OWNER:
			if FofObject.ascended: return info.ascended_description
	return info.description
	
func getIcon() -> Texture2D:
	return info.icon
	
func onSave() -> SavedData:
	var fof_object_public_id: int = FofObject.public_id if FofObject != null else 0
	return SavedDataFieldEffect.new(info.id, false, public_id, fof_object_public_id, charges, turns, ability_save)

func onLoadData(data: SavedData) -> void:
	super(data)
	ability_save = data.ability_save
	turns = data.turns
	
	if data.fof_object_public_id != 0:
		FofObject = Game.onFindPublicIDObject(data.fof_object_public_id)
		
	for custom_variable in ability_save:
		set(custom_variable, ability_save[custom_variable])
		
	setCharges(data.charges)
		
func onRemoveFromCard() -> void: # Removes field effect from the card, interface using RemoveFieldEffectAction
	Card.onRemoveFieldEffect(self)
	
func setCharges(_charges: int) -> void:
	charges = _charges
	update_charges.emit(charges)
	
func onLevelEnded(_win: bool) -> void:
	onClear()
	
func getCharges() -> int:
	return charges

func onFieldEffectAdded() -> void: pass
