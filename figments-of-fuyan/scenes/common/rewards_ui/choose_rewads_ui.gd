extends Control

signal taken
signal mouse_signal

@onready var CardsContainer: HBoxContainer = %CardsContainer
func setInfo(rewards: ActionWrapper) -> void:
	for reward: FofGD in rewards.getType(ChooseRewardAction)[0].getItems():
		if reward is CardGD:
			var CardUI: Control = reward.onCreateCardUI(CardsContainer, true)
			CardUI.mouse_in_ui.connect(onMouseInUI)
			CardUI.pressed.connect(onCardPressed)

var mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	mouse_in_ui = state
	mouse_signal.emit(mouse_in_ui)
	
func onCardPressed(CardUI: Control) -> void:
	var Card: CardGD = CardUI.Card
	Game.getArea().onPushAction(AddToDeckAction.new(Card))
	
	queue_free()
	taken.emit(Card)
