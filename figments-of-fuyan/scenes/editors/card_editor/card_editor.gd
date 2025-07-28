extends Node

const START_X: int = -12
const OFFSET: int = 3
const CARD_UI_OFFSET := Vector2(-120, -400)

@export var ActionManagerPacked: PackedScene
@export var EDITABLE_CARD_UI_PACKED: PackedScene

@onready var TieredCardGrid: GridContainer = %TieredCardGrid
@onready var CardGrid: GridContainer = %CardGrid
@onready var SearchAreaCard: LineEdit = %SearchAreaCard
@onready var CardParent: Node3D = %CardParent

func _ready() -> void:
	#var ActionManager: Node = ActionManagerPacked.instantiate()
	#add_child(ActionManager)
	#Game.ActionManagerReference = ActionManager
	
	var card_id_to_area_id: Dictionary[int, int] = {}
	for area_info: AreaInfo in Helper.getFofInfoArray(AreaInfo):
		for id: int in area_info.card_ids:
			card_id_to_area_id[id] = area_info.id
	
	var card_infos: Array = Helper.getFofInfoArray(CardInfo)
	card_infos.sort_custom(getSortValue.bind(card_id_to_area_id))
	
	for card_info: CardInfo in card_infos:
		var card_data := SavedDataCard.new(card_info.id, true)
		Game.setCardDataFromInfo(card_data, card_info)
		var Card: CardGD = SavedData.onLoadModel(card_data, CardParent)
		
		var arr: Array[ActiveEffectDatastore] = []
		arr.assign(Card.info.active_abilities)
		
		for a: ActiveEffectDatastore in arr:
			a.charges = a.max_charges
		
		Card.active_effects = arr
		onCreateDeckCardUI(Card)

func getSortValue(x: CardInfo, y: CardInfo, card_id_to_area_id: Dictionary[int, int]) -> bool:
	if card_id_to_area_id[x.id] != card_id_to_area_id[y.id]: return card_id_to_area_id[x.id] < card_id_to_area_id[y.id]
	if x.rarity != y.rarity: return x.rarity < y.rarity
	if x.energy != y.energy: return x.energy < y.energy
	return x.id < y.id
func onAnimationNameButtonPressed(ani_name: String) -> void:
	for Card in get_tree().get_nodes_in_group("CardsGD").filter(func(x: CardGD): return x.AniPlayer != null and x.AniPlayer.has_animation(ani_name)):
		Card.AniPlayer.play(ani_name)

func onCreateDeckCardUI(Card: CardGD) -> void:
	var CardUI: Control = Card.onCreateCardUI(CardGrid, true, true)
	CardUI.pressed.connect(onCardUIPressed)
	
	var ArchetypeLabel := Label.new()
	ArchetypeLabel.text = Card.getArchetypeFromInfo().name
	CardUI.add_child(ArchetypeLabel)
	ArchetypeLabel.position = Vector2(0, -5)
	ArchetypeLabel.size.x = CardUI.size.x
	ArchetypeLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

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
func onCardUIPressed(CardUI: Control) -> void:
	var card_info: CardInfo = CardUI.Card.info
	if card_info.tiers.size() < 4:
		for i: int in range(4 - card_info.tiers.size()):
			card_info.tiers.append(CardTierDatastore.new())
				
	ResourceSaver.save(card_info)
	for EditableCardUI: Control in TieredCardGrid.get_children():
		EditableCardUI.onSaveToCardInfo()
		EditableCardUI.queue_free()
	
	for tier: int in range(1, 5):
		var EditableCardUI: Control = EDITABLE_CARD_UI_PACKED.instantiate()
		TieredCardGrid.add_child(EditableCardUI)
		EditableCardUI.setInfo(card_info, tier)
#endregion

func _on_tier_up_button_pressed() -> void:
	for Card: CardGD in get_tree().get_nodes_in_group("CardsGD"):
		var next_tier: int = (Card.getTier() + 1) % (Card.info.tiers.size() + 1)
		if next_tier == 0: next_tier = 1
		Card.onRetiered(next_tier)
