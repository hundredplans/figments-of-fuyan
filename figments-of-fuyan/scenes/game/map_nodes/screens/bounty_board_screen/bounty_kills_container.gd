extends HBoxContainer

signal card_pressed

@onready var BountyKillLabel: Label = %BountyKillLabel
func setInfo(kill_amount: int, cards: Array) -> void:
	BountyKillLabel.text = str(kill_amount)
	for Card in cards:
		var claimable: bool = (kill_amount > Card.getLastClaimedKills())
		var CardUI: Control = Card.onCreateCardUI(self, claimable)
		CardUI.setDisabled(claimable)
		if claimable:
			CardUI.pressed.connect(onCardPressed)

func onCardPressed(CardUI: Control) -> void:
	card_pressed.emit(CardUI.Card)
