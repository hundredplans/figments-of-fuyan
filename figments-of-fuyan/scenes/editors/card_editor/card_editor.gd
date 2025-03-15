extends Node

const START_X: int = -12
const OFFSET: int = 3
const CARD_UI_OFFSET := Vector2(-120, -400)

@onready var CardGrid: GridContainer = %CardGrid
@onready var SearchAreaCard: LineEdit = %SearchAreaCard
@onready var CardParent: Node3D = %CardParent

var card_id_to_area_id: Dictionary[int, int]
func _ready() -> void:
	for area_info: AreaInfo in Helper.getFofInfoArray(AreaInfo):
		for id: int in area_info.card_ids:
			card_id_to_area_id[id] = area_info.id
	
	var card_infos: Array = Helper.getFofInfoArray(CardInfo)
	
	for card_info in card_infos:
		var card_data := SavedDataCard.new(card_info.id, true)
		Game.setCardDataFromInfo(card_data, card_info)
		var Card: CardGD = SavedData.onLoadModel(card_data, CardParent)
		onCreateDeckCardUI(Card)

func getSortValue(x: CardInfo, y: CardInfo) -> bool:
	var area_x: int = card_id_to_area_id[x.id]
	var area_y: int = card_id_to_area_id[y.id]
	
	if area_x < area_y:
		return true
	elif area_x > area_y:
		return false
	
	if x.rarity < y.rarity:
		return true
	elif x.rarity > y.rarity:
		return false
		
	if x.energy < y.energy:
		return true
	elif x.energy > y.energy:
		return false
		
	if x.id < y.id:
		return true
	elif x.id > y.id:
		return false
	return false

func onAnimationNameButtonPressed(ani_name: String) -> void:
	for Card in get_tree().get_nodes_in_group("CardsGD").filter(func(x: CardGD): return x.AniPlayer != null and x.AniPlayer.has_animation(ani_name)):
		Card.AniPlayer.play(ani_name)

func onCreateDeckCardUI(Card: CardGD) -> void:
	var CardUI: Control = Card.onCreateCardUI(CardGrid, true, true)
	CardUI.pressed.connect(onCardUIPressed)
	
	var ArchetypeLabel := Label.new()
	ArchetypeLabel.text = Card.info.archetype.name
	CardUI.add_child(ArchetypeLabel)
	ArchetypeLabel.position = Vector2(0, -5)
	ArchetypeLabel.size.x = CardUI.size.x
	ArchetypeLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
func _input(_event: InputEvent) -> void:
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
	CardSpotCard.position = CardSpot.size / 4
#endregion
