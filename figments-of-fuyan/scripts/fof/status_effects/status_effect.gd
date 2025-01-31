class_name StatusEffectGD extends FofGD

var Card: CardGD
var turns: int
var ability_save: Dictionary

#region Save / Load
func onSave() -> SavedData:
	return SavedDataStatusEffect.new(info.id, false, public_id, turns, ability_save)
	
func onLoadData(data: SavedData) -> void:
	turns = data.turns
	ability_save = data.ability_save
	
	for custom_variable in ability_save:
		set(custom_variable, ability_save[custom_variable])

func onClear() -> void:
	super()
	Card.onRemoveStatusEffect(self)
#endregion

#region Icons
func getIcon() -> Texture2D:
	return info.icon
#endregion

func onProcessAction(action: Action) -> void:
	if action.post:
		if action is ChangeTurnStateAction:
			if action.turn_state == Game.TurnStates.PASSED and action.Card == Card and turns > 0:
				turns -= 1
				if turns == 0:
					onPushAction(RemoveStatusEffectAction.new(self))
			
		elif action is DeathAction and action.Defender == Card:
			onClear()
		
		elif action is AddStatusEffectAction and action.StatusEffect == self:
			onStatusEffectAdded(action)
	
func getDescription() -> String:
	return info.description
	
func onStatusEffectAdded(_action: AddStatusEffectAction) -> void:
	pass

func onLevelEnded(_win: bool) -> void:
	onClear()
