extends Purchasable
@onready var PanelButton: Control = %PanelButton
@onready var SoldLabel: Label = %SoldLabel

@export var DeckScreenPacked: PackedScene
var DeckScreen: Control

func setInfo(_item: FofGD, _price_datastore: PriceDatastore, _save_file: SaveFileGD) -> void:
	super(_item, _price_datastore, _save_file)
	var text: String = item.info.name
	PanelButton.setText(text)
	PanelButton.pressed.connect(onCreateDeckScreen)

func setDisabled(state: bool = true) -> void:
	super(state)
	PanelButton.setDisabled(state)
	
func onCreateDeckScreen() -> void:
	DeckScreen = DeckScreenPacked.instantiate()
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
	
	var CardUI: Control = DeckScreen.SelectedCardUI
	var card_ui_position: Vector2 = CardUI.global_position
	CardUI.reparent(self)
	CardUI.global_position = card_ui_position
	
	CardUI.highlight_on_hover = false
	DisplayedUI = CardUI
	
	onPressed()
	
func onPressed(_load_bought: bool = false) -> void:
	super()
	SoldLabel.visible = true
	PanelButton.setText("")
	setDisabled(true)
