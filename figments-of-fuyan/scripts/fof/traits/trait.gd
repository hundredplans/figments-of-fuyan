class_name TraitGD extends GameEffectGD

var Card: CardGD
var display_number: int
var turns: int

func onSave() -> SavedData:
	return SavedDataTrait.new(info.id, false, public_id, display_number, turns)
	
func onLoadData(data: SavedData) -> void:
	super(data)
	display_number = data.display_number
	turns = data.turns

func getIcon() -> Texture2D:
	return info.icon
	
func getTurns() -> int:
	return turns

func getDescription() -> String:
	return info.description

func onProcessAction(action: Action) -> void:
	if action.post:
		if action is AddTraitAction and action.overworld_trait.Trait == self:
			onTraitAdded()
			
func onTraitAdded() -> void:
	pass

func onLevelEnded(_win: bool) -> void:
	onClear()
	
func setDisplayNumber(_display_number: int) -> void:
	display_number = _display_number
	update_display_number.emit(display_number)

func getDisplayNumber() -> int:
	return display_number

func onCardTurnPassed(added_by: OverworldTrait.AddedBy) -> void:
	if turns == -1: return
	turns -= 1
	update_turns.emit(turns)
	
	if turns == 0:
		onPushAction(RemoveOverworldTraitAction.new(Card, info.id, added_by))
