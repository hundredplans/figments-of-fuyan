extends Control

signal mouse_in_ui
@onready var FadeBackground: Control = %FadeBackground
@onready var CardContainer: Container = %CardContainer
@onready var GraveyardLabel: Label = %GraveyardLabel
func setInfo(bg_color: Color) -> void:
	FadeBackground.color = bg_color 
	FadeBackground.FADE_COLOR = bg_color
	FadeBackground.onFade(true)
	
	for FadeNode: Control in [GraveyardLabel]:
		FadeNode.modulate.a = 0
		var tween := create_tween()
		tween.tween_property(FadeNode, "modulate:a", 1.0, Game.FADE_TIME)
	
	for Card: CardGD in get_tree().get_nodes_in_group("GraveyardCardsGD"):
		var CardUI: TbcUI = Card.onCreateCardUI(CardContainer, true, false, false)
		CardUI.onCreateTeamIdentifier()

func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
