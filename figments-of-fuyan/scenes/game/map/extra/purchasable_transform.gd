extends Purchasable
@onready var PanelButton: Control = %PanelButton
@onready var SoldLabel: Label = %SoldLabel

@export var DeckScreenPacked: PackedScene
var DeckScreen: Control

func setInfo(_item: FofGD, _price_datastore: PriceDatastore, _save_file: SaveFileGD) -> void:
	super(_item, _price_datastore, _save_file)
	var text: String
	if item.hasType(TransformCardAction):
		var transform_action: TransformCardAction = item.getType(TransformCardAction)[0]
		if transform_action.transform_type == TransformCardAction.TransformType.Energy: text = "Transform by Energy"
		if transform_action.transform_type == TransformCardAction.TransformType.Rarity: text = "Transform by Rarity"
	
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
	
	var action: Action = item.getActions()[0]
	if action is TransformCardAction and action.transform_type == TransformCardAction.TransformType.Rarity: # By rarity
		DeckScreen.onDisableCards(func(x: Control): return Game.isChampion(x.Card.info.rarity))
	elif action is TransformCardAction and action.transform_type == TransformCardAction.TransformType.Energy: # By cost
		DeckScreen.onDisableCards(func(x: Control): return Game.isChampion(x.Card.info.rarity))
	
func onCardSelected(Card: CardGD) -> void:
	item.setForType(TransformCardAction, Card, "Card") # Works if it's either
	item.onUse()
	
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
