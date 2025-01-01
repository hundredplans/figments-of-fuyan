extends Node

const START_X: int = -12
const OFFSET: int = 3
const CARD_UI_OFFSET := Vector2(-120, -400)

@onready var CardUIHolder: Control = %CardUIHolder
@onready var CardGrid: GridContainer = %CardGrid
@onready var SearchAreaCard: LineEdit = %SearchAreaCard
@onready var CardParent: Node3D = %CardParent

func _ready() -> void:
	var start_x: int = START_X
	var start_z: int = 0
	
	for card_info in Helper.getFofInfoArray(CardInfo):
		var card_data := SavedDataCard.new(card_info.id, true)
		Game.setCardDataFromInfo(card_data, card_info)
		var Card: CardGD = SavedData.onLoadModel(card_data, CardParent)
		onCreateDeckCardUI(Card)

func onAnimationNameButtonPressed(ani_name: String) -> void:
	for Card in get_tree().get_nodes_in_group("CardsGD").filter(func(x: CardGD): return x.AniPlayer != null and x.AniPlayer.has_animation(ani_name)):
		Card.AniPlayer.play(ani_name)

func onCreateDeckCardUI(Card: CardGD) -> void:
	var CardUI: Control = Card.onCreateCardUI(CardGrid, true, true)
	CardUI.pressed.connect(onCardUIPressed)
	Card.mouse_entered.connect(onCreateCardUI)
	Card.mouse_exited.connect(onRemoveCardUI)

var HoverCardUI: Control
func onCreateCardUI(Card: CardGD) -> void:
	HoverCardUI = Card.onCreateCardUI(CardUIHolder)
	setCardUIPosition()
	
func onRemoveCardUI(_Card: CardGD) -> void:
	if HoverCardUI != null: HoverCardUI.queue_free()
	
func setCardUIPosition() -> void:
	HoverCardUI.position = get_viewport().get_mouse_position() + CARD_UI_OFFSET
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and HoverCardUI != null:
		setCardUIPosition()
	if Input.is_action_just_pressed("FocusControl"):
		if SearchAreaCard.has_focus():
			SearchAreaCard.release_focus()
		else: SearchAreaCard.grab_focus()

func _on_ascend_button_pressed() -> void:
	for Card in get_tree().get_nodes_in_group("CardsGD"):
		Card.onAscend(!Card.ascended)

func _on_search_area_card_text_changed(text: String) -> void:
	var area_name_to_unit_id: Dictionary
	for area_info in Helper.getFofInfoArray(AreaInfo):
		area_name_to_unit_id[area_info.name] = area_info.card_ids
		
	for CardUI in CardGrid.get_children():
		CardUI.visible = CardUI.Card.info.name.to_lower().begins_with(text.to_lower())
		
	for area_name in area_name_to_unit_id:
		if area_name.to_lower().begins_with(text.to_lower()):
			for CardUI in CardGrid.get_children().filter(func(x: Control): return x.Card.info.id in area_name_to_unit_id[area_name]):
				CardUI.visible = true

#region CardSpot
@onready var CardSpot: Control = %CardSpot
var CardSpotCard: Control
func onCardUIPressed(CardUI: Control) -> void:
	if CardSpotCard != null: CardSpotCard.queue_free()	
	var Card: CardGD = CardUI.Card
	CardSpotCard = Card.onCreateCardUI(CardSpot)
	CardSpotCard.scale = Vector2(2, 2)
#endregion

func _on_movement_camera_camera_panning(_state: bool) -> void:
	if HoverCardUI != null: HoverCardUI.queue_free()
