extends Control

signal exit_start
signal mouse_in_ui
@onready var FadeBackground: Control = %FadeBackground
@onready var CardContainer: Container = %CardContainer
@onready var GraveyardLabel: Label = %GraveyardLabel
func setInfo(bg_color: Color) -> void:
	FadeBackground.color = bg_color 
	FadeBackground.FADE_COLOR = bg_color
	
	for Card: CardGD in get_tree().get_nodes_in_group("GraveyardCardsGD"):
		var CardUI: TbcUI = Card.onCreateCardUI(CardContainer, true, false, false)
		CardUI.mouse_in_ui.connect(onMouseInUI)
		CardUI.onCreateTeamIdentifier()
	await onFade(true)

func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)

func onFade(fade_in: bool) -> void:
	for FadeNode: Control in [GraveyardLabel, CardContainer]:
		FadeNode.modulate.a = 0 if fade_in else 1.0
		var tween := create_tween()
		tween.tween_property(FadeNode, "modulate:a", 1.0 if fade_in else 0.0, Game.FADE_TIME)
	await FadeBackground.onFade(fade_in)
	if !fade_in:
		queue_free()
