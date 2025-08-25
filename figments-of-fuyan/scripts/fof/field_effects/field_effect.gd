class_name FieldEffectGD extends FofGD

signal update_display_number

var Card: CardGD
var FofObject: FofGD # Equivalent to owner
var ability_save: Dictionary
var display_number: int

var charges: int = -1
var turns: int = -1

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is ChangeTurnStateAction and action.turn_state == Game.TurnStates.PASSED and action.Card == Card:
			onCardTurnPassed()
			
		elif action is DeathAction and action.Defender == Card:
			onPushAction(RemoveFieldEffectAction.new(self))
		
		elif info.remove_on_owner_death and action is DeathAction and action.Defender == FofObject:
			onPushAction(RemoveFieldEffectAction.new(self))

func onCardTurnPassed() -> void:
	if turns > 0:
		setTurns(max(turns - 1, 0))
		if turns == 0: onPushAction(RemoveFieldEffectAction.new(self))
		
func setTurns(_turns: int) -> void:
	turns = _turns
	if info.display_number_type == FieldEffectInfo.DisplayNumberType.TURNS:
		setDisplayNumber(turns)

func getDescription() -> String:
	return info.description
	
func getIcon() -> Texture2D:
	return info.icon
	
func onSave() -> SavedData:
	var fof_object_public_id: int = FofObject.public_id if FofObject != null else 0
	return SavedDataFieldEffect.new(info.id, false, public_id, fof_object_public_id, charges, turns, display_number, ability_save)

func onLoadData(data: SavedData) -> void:
	super(data)
	ability_save = data.ability_save
	display_number = data.display_number
	
	if data.fof_object_public_id != 0:
		FofObject = Game.onFindPublicIDObject(data.fof_object_public_id)
		
	for custom_variable in ability_save:
		set(custom_variable, ability_save[custom_variable])
		
	setTurns(data.turns)
	setCharges(data.charges)
		
func onRemoveFromCard() -> void: # Removes field effect from the card, interface using RemoveFieldEffectAction
	Card.onRemoveFieldEffect(self)
	
func setCharges(_charges: int) -> void:
	charges = _charges
	if info.display_number_type == FieldEffectInfo.DisplayNumberType.CHARGES:
		setDisplayNumber(charges)
	
func setDisplayNumber(_display_number: int) -> void:
	display_number = _display_number
	update_display_number.emit(display_number)
	
func getDisplayNumber() -> int:
	return display_number
	
func onLevelEnded(_win: bool) -> void:
	onClear()
	
func getCharges() -> int:
	return charges

func getFofObject() -> FofGD: return FofObject
func onForceUpdateDisplayNumber() -> void: pass
func onFieldEffectAdded() -> void: pass
