class_name StatusEffectGD extends FofGD

var Card: CardGD
var turns: int
var ability_save: Dictionary
var Creator: FofGD

#region Save / Load
func onSave() -> SavedData:
	var creator_public_id: int = Creator.public_id if Creator != null else 0
	return SavedDataStatusEffect.new(info.id, false, public_id, turns, creator_public_id, ability_save)
	
func onLoadData(data: SavedData) -> void:
	turns = data.turns
	ability_save = data.ability_save
	Creator = Game.onFindPublicIDObject(data.creator_public_id)
	
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
	super(action)
	if action.post:
		if action is ChangeTurnStateAction:
			if action.turn_state == Game.TurnStates.PASSED and action.Card == Card and (self is not FatigueGD) and turns > 0:
				turns -= 1
				if turns == 0:
					onPushAction(RemoveStatusEffectAction.new(self))
			
		elif action is DeathAction and action.Defender == Card:
			onClear()
	
func getDescription() -> String:
	return info.description
	
func onStatusEffectAdded(_action: AddStatusEffectAction) -> void:
	pass

func onLevelEnded(_win: bool) -> void:
	onClear()
