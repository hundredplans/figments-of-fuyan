extends Control

signal pressed
const CARD_UI_POSITION := Vector2(197, 314)
var CardUI: Control

@export_multiline var elite_text: String
@export_multiline var miniboss_text: String
@export_multiline var boss_text: String

@onready var ChooseLabel: RichTextLabel = %ChooseLabel

var reward: Reward
var taken: bool

func setInfo(_reward: Reward) -> void:
	reward = _reward
	CardUI = reward.item.onCreateCardUI(self, true)
	CardUI.scale = Vector2(2, 2)
	CardUI.position = CARD_UI_POSITION
	CardUI.pressed.connect(onCardUIPressed)
	
	match reward.item.info.rarity:
		Game.Rarities.EXALT: ChooseLabel.setText(elite_text)
		Game.Rarities.MINIBOSS: ChooseLabel.setText(miniboss_text)
		Game.Rarities.BOSS: ChooseLabel.setText(boss_text)
		
	setTaken(reward.taken)

func onCardUIPressed(_CardUI: Control) -> void:
	pressed.emit(reward)

func setTaken(state: bool) -> void:
	taken = state
	CardUI.setDisabled(taken)
