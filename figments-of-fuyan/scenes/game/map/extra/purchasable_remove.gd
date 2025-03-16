extends Purchasable
@onready var PanelButton: Control = %PanelButton
@export var DeckScreenPacked: PackedScene

const REMOVE_CARD_PRICE_INCREASE: int = 10

func setInfo(_item: FofGD, _price_datastore: PriceDatastore, _save_file: SaveFileGD) -> void:
	super(_item, _price_datastore, _save_file)
	PanelButton.pressed.connect(onRemovePressed)
	
func setDisabled(state: bool = true) -> void:
	super(state)
	PanelButton.setDisabled(state)

func onRemovePressed() -> void:
	var DeckScreen: Control = DeckScreenPacked.instantiate()
	create_screen.emit(DeckScreen)
	DeckScreen.setInfo(true)
	DeckScreen.selected.connect(onCardSelected)
	DeckScreen.onDisableCards(func(x: Control): return Game.isChampion(x.Card.info.rarity))

func onCardSelected(Card: CardGD) -> void:
	item.setForType(RemoveFromDeckAction, Card, "Card")
	item.onUse()
	
	onPressed()
	
	price_datastore.bought = false
	price_datastore.price += REMOVE_CARD_PRICE_INCREASE
	setShillingsLabel()

func onPressed(_load_bought: bool = false) -> void:
	super()
