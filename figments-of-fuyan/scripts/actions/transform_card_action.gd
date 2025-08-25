class_name TransformCardAction extends Action

enum TransformType {RARITY, ENERGY}

var NewCard: CardGD
var Card: CardGD
@export var transform_type: TransformType

var all: Array

func _init(_Card: CardGD = null, _transform_type := TransformType.RARITY) -> void:
	super()
	Card = _Card
	transform_type = _transform_type
	
func onPreAction() -> void:
	all = Helper.getFofInfoArray(CardInfo)
	all = all.filter(func(x: FofInfo): return x != Card.info and x.rarity == Card.getRarity())
	if all.is_empty(): onFailAction(); return
	
func onPostAction() -> void:
	#if transform_type == TransformType.ENERGY: onTransformByEnergy()
	if transform_type == TransformType.RARITY: onTransformByRarity()
		
func onTransformByRarity() -> void:
	var new_info: FofInfo = all.pick_random()
	var new_data: SavedData = new_info.saved_data.new(new_info.id, true)
	
	new_data.tier = Card.getTier()
	Game.setCardDataFromInfo(new_data, new_info)
	
	var tool_data: SavedDataTool = null if Card.getTool() == null else Card.getTool().onSave()
	new_data.tool_data = tool_data
	
	NewCard = SavedData.onLoadModel(new_data, Game.getSaveFile())
	
	var override_deck_slot: DeckSlot = Game.getSaveFile().getDeckSlotByPublicID(Card.public_id)
	var remove_from_deck_action := RemoveFromDeckAction.new(Card, true)
	var add_to_deck_action := AddToDeckAction.new(NewCard, override_deck_slot)
	
	if !forced: onPushAction([remove_from_deck_action, add_to_deck_action])
	else: onForceAction(remove_from_deck_action); onForceAction(add_to_deck_action)
		
#func onTransformByEnergy() -> void:
	#var cards: Array = Helper.getFofInfoArray(CardInfo)
	#cards = cards.filter(func(x: CardInfo):\
		#return x != Card.info\
		#and x.rarity in [Game.Rarities.COMMON, Game.Rarities.RARE, Game.Rarities.EXALT]\
		#and x.energy == Card.energy)
		#
	#if !cards.is_empty():
		#var new_card_info: CardInfo = cards.pick_random()
		#var new_card_data: SavedDataCard = new_card_info.saved_data.new(new_card_info.id, true)
		#Game.setCardDataFromInfo(new_card_data, new_card_info)
		#
		#var tool_data: SavedDataTool = null if Card.getTool() == null else Card.getTool().onSave()
		#new_card_data.tool_data = tool_data
		#new_card_data.tier = Card.tier
		#
		#NewCard = SavedData.onLoadModel(new_card_data, Game.getSaveFile())
		#var actions: Array = [RemoveFromDeckAction.new(Card), AddToDeckAction.new(NewCard)]
		#onPushAction(actions)
	
func getNewCard() -> CardGD:
	return NewCard
