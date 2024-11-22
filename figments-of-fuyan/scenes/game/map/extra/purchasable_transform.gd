extends Purchasable
@onready var PanelButton: Control = %PanelButton
@onready var SoldLabel: Label = %SoldLabel

@export var DeckScreenPacked: PackedScene

func setInfo(_item: FofGD, _price_datastore: PriceDatastore, save_file: SaveFileGD) -> void:
	super(_item, _price_datastore, save_file)
	var text: String = item.info.name
	PanelButton.setText(text)
	PanelButton.pressed.connect(onCreateDeckScreen)

func setDisabled(state: bool = true) -> void:
	super(state)
	PanelButton.setDisabled(state)
	
func onCreateDeckScreen() -> void:
	var DeckScreen: Control = DeckScreenPacked.instantiate()
	create_screen.emit(DeckScreen)
	DeckScreen.setInfo(true)
	DeckScreen.selected.connect(onCardSelected)
	
	if item.info.id == 4: # Ascend
		DeckScreen.onDisableCards(func(x: Control): return Game.isChampion(x.Card.info.rarity) or x.Card.ascended)
	elif item.info.id == 5: # By rarity
		DeckScreen.onDisableCards(func(x: Control): return Game.isChampion(x.Card.info.rarity))
	elif item.info.id == 6: # By cost
		DeckScreen.onDisableCards(func(x: Control): return Game.isChampion(x.Card.info.rarity))
	
func onCardSelected(Card: CardGD) -> void:
	if item.info.id == 4: item.onPickup(Card)
	else: item.onPickup(Card, save_file)
	
	onPressed()
	
func onPressed() -> void:
	super()
	SoldLabel.visible = true
	PanelButton.setText("")
	setDisabled(true)
