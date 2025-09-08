extends Purchasable
@onready var MainContainer: Container = %MainContainer

func setInfo(_price_datastore: PriceDatastore) -> void:
	var card_data: SavedDataCard = _price_datastore.getData()
	card_data.public_id = 0
	
	if card_data.tool_data != null:
		card_data.tool_data.public_id = 0
	
	var Card: CardGD = SavedData.onLoadModel(card_data, Game.getArea().getEnteredMapNode())
	DisplayedUI = Card.onCreateCardUI(self, true, false, true, true)
	DisplayedUI.onShowTierLabel()
	DisplayedUI.pressed.connect(func(__: Control): onPressed())
	PriceLabel.reparent(DisplayedUI)
	
	super(_price_datastore)
	
func setDisabled(state: bool = true) -> void:
	super(state)
	DisplayedUI.setDisabled(state)

func getSoldLabelPosition(SoldLabel: Label) -> Vector2:
	return super(SoldLabel) + Vector2(5, 0)
