extends BoonGD

var stunned_cards: Array
var stunned_cards_public_ids: Array
func onProcessAction(action: Action):
	super(action)
	if action.post:
		if action is VisionNewUnitAction:
			onCheckReveal(action.Discovered, action.Discoverer)
			onCheckReveal(action.Discoverer, action.Discovered)
				
func onCheckReveal(Revealer: CardGD, Revealed: CardGD) -> void:
	if Revealer.isAlly(1) and Revealed.isAlly(0) and Revealed not in stunned_cards:
		Revealed.onStun(1)
		stunned_cards.append(Revealed)
				
func onAscend(state: bool):
	super(state)

func onBoon(_action: Action = null):
	pass

func onBoonAdded():
	pass

func getDisabled():
	return super()
	
func onSave() -> SavedDataBoon:
	ability_save['stunned_cards_public_ids'] = stunned_cards.map(func(x: CardGD): return x.public_id)
	return super()
	
func onLoadData(data: SavedData) -> void:
	super(data)
	stunned_cards = stunned_cards_public_ids.map(func(x: int): return Game.onFindPublicIDObject(x))
