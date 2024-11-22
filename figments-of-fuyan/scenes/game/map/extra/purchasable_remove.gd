extends Purchasable
@onready var PanelButton: Control = %PanelButton
@onready var SoldLabel: Label = %SoldLabel
@export var DeckScreenPacked: PackedScene

func setInfo(_item: FofGD, _price_datastore: PriceDatastore, save_file: SaveFileGD) -> void:
	super(_item, _price_datastore, save_file)
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
	item.onPickup(Card)
	onPressed() 

func onPressed() -> void:
	super()
	SoldLabel.visible = true
	PanelButton.setText("")
	setDisabled(true)
