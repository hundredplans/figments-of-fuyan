extends Control

signal pressed
const CARD_UI_POSITION := Vector2(197, 314)
var CardUI: Control
var taken: bool

@export_multiline var elite_text: String
@export_multiline var miniboss_text: String
@export_multiline var boss_text: String

@onready var ChooseLabel: RichTextLabel = %ChooseLabel

func setInfo(Card: CardGD, _taken: bool) -> void:
	CardUI = Card.onCreateCardUI(self, true)
	CardUI.scale = Vector2(2, 2)
	CardUI.position = CARD_UI_POSITION
	CardUI.pressed.connect(onCardUIPressed)
	
	match Card.info.rarity:
		Game.Rarities.EXALT: ChooseLabel.setText(elite_text)
		Game.Rarities.MINIBOSS: ChooseLabel.setText(miniboss_text)
		Game.Rarities.BOSS: ChooseLabel.setText(boss_text)
		
	setTaken(_taken)

func onCardUIPressed(_CardUI: Control) -> void:
	pressed.emit(_CardUI.Card)

func setTaken(_taken: bool) -> void:
	taken = _taken
	CardUI.setDisabled(taken)
