class_name StatusEffectGD extends FofGD

var Card: CardGD
var turns: int

#region Save / Load
func onSave() -> SavedData:
	return SavedDataStatusEffect.new(info.id, false, public_id, turns)
	
func onLoadData(data: SavedData) -> void:
	turns = data.turns

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
		if action is ChangePhaseAction and action.phase == Game.Phases.PLAYER:
			if turns > 0 and Game.isAdvanceTurn(action.phase, Card.team):
				turns -= 1
				if turns == 0: onPushAction(RemoveStatusEffectAction.new(self))
			
		elif action is DeathAction and action.Defender == Card:
			onClear()
			
func onAdvanceTurn() -> void:
	pass
	
func getDescription() -> String:
	return info.description
	
