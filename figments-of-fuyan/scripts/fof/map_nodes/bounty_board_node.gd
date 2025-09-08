extends MapNodeGD

signal change_shillings

#Changes to Bounty Board
#Start at 8 SH (+4 SH per uses in the arena) (Duels count as 2 kills) (energy rules for the kills)
#You can choose between +1 ATT or +1 HP
#
#1 KILL
#5 KILL
#10 KILL
#20 KILL
#50 KILL
#100 KILL
	
var price: int
var selected_card_public_id: int

func onSave() -> SavedDataMapNode:
	ability_save['price'] = price
	ability_save['selected_card_public_id'] = selected_card_public_id
	return super()

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is ChangeShillingsAction:
			change_shillings.emit()
