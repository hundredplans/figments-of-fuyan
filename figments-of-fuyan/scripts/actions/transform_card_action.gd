class_name TransformCardAction extends Action

enum TransformType {Energy, Rarity}
var NewCard: CardGD # Created after transform is applied
var Card: CardGD
@export var transform_type: TransformType

func _init(_Card: CardGD = null, _transform_type := TransformType.Energy) -> void:
	super()
	Card = _Card
	transform_type = _transform_type
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	if transform_type == TransformType.Energy: onTransformByEnergy()
	elif transform_type == TransformType.Rarity: onTransformByRarity()
		
func onTransformByEnergy() -> void:
	var cards: Array = Helper.getFofInfoArray(CardInfo)
	cards = cards.filter(func(x: CardInfo):\
		return x != Card.info\
		and x.rarity in [Game.Rarities.COMMON, Game.Rarities.RARE, Game.Rarities.EXALT]\
		and x.energy == Card.energy)
		
	if !cards.is_empty():
		var new_card_info: CardInfo = cards.pick_random()
		var new_card_data: SavedDataCard = new_card_info.saved_data.new(new_card_info.id, true)
		Game.setCardDataFromInfo(new_card_data, new_card_info)
		
		var tool_data: SavedDataTool = null if Card.getTool() == null else Card.getTool().onSave()
		new_card_data.tool_data = tool_data
		new_card_data.ascended = Card.ascended
		
		NewCard = SavedData.onLoadModel(new_card_data, Game.getSaveFile())
		var actions: Array = [RemoveFromDeckAction.new(Card), AddToDeckAction.new(NewCard)]
		onPushAction(actions)
		
func onTransformByRarity() -> void:
	var cards: Array = Helper.getFofInfoArray(CardInfo)
	cards = cards.filter(func(x: CardInfo):\
		return x != Card.info\
		and x.rarity == Card.info.rarity)
		
	if !cards.is_empty():
		var new_card_info: CardInfo = cards.pick_random()
		var new_card_data: SavedDataCard = new_card_info.saved_data.new(new_card_info.id, true)
		Game.setCardDataFromInfo(new_card_data, new_card_info)
		
		var tool_data: SavedDataTool = null if Card.getTool() == null else Card.getTool().onSave()
		new_card_data.tool_data = tool_data
		new_card_data.ascended = Card.ascended
		
		NewCard = SavedData.onLoadModel(new_card_data, Game.getSaveFile())
		var actions: Array = [RemoveFromDeckAction.new(Card), AddToDeckAction.new(NewCard)]
		onPushAction(actions)
