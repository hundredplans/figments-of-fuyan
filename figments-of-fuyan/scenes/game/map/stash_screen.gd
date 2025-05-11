extends Control

signal exit_start
signal deck_slot_changed
signal mouse_in_ui

@onready var CardUIRaycast: RayCast2D = %CardUIRaycast
@onready var EnergyLimitLabel: Label = %EnergyLimitLabel
@onready var DeckLimitLabel: Label = %DeckLimitLabel
@onready var DeckContainer: Container = %DeckContainer
@onready var StashContainer: Container = %StashContainer
@onready var AniPlayer: AnimationPlayer = %AniPlayer
@onready var MainScrollContainer: Container = %MainScrollContainer
@onready var BoonScrollContainer: Container = %BoonScrollContainer

@onready var EnergyLimitTexture: TextureRect = %EnergyLimitTexture
@onready var EnergyLimitContainer: Container = %EnergyLimitContainer
@onready var FadeCreamBackground: Control = %FadeCreamBackground

@onready var BoonBox: Container = %BoonBox

@export var DeckSlotPacked: PackedScene

const DECK_SLOTS_GAP: int = 50
const DECK_SLOT_SIZE := Vector2(400, 500)
const SCROLL_TIME: float = 0.5

const DECK_CONTAINER_SPLIT_POINT: Dictionary[int, int] = { # Amount of slots to split point
	5: 5,
	6: 3,
	7: 4,
	8: 4,
	9: 5,
	10: 5
}

func setInfo() -> void:
	AniPlayer.play("SlideUIElements")
	FadeCreamBackground.onFade(true)
	
	BoonBox.onUpdate()
	var deck_slots: Array = Game.getSaveFile().getDeckSlots()
	setLimitLabels()
	
	DeckContainer.add_theme_constant_override("separation", DECK_SLOTS_GAP)
	for __: int in range(ceil(deck_slots.size() / 5.0)):
		var hbox := HBoxContainer.new()
		hbox.custom_minimum_size.y = 410
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE
		hbox.add_theme_constant_override("separation", DECK_SLOTS_GAP)
		DeckContainer.add_child(hbox)
	
	var i: int = 0
	for deck_slot: DeckSlot in deck_slots:
		var DeckSlotUI: Control = DeckSlotPacked.instantiate()
		DeckSlotUI.mouse_in_ui.connect(onMouseInUI)
		DeckSlotUI.lock_slot.connect(onSlotLocked)
		DeckSlotUI.send_to_stash.connect(onSendToStash)
		DeckSlotUI.pressed.connect(onDeckSlotPressed)
		DeckSlotUI.remove_deck_card.connect(onRemoveDeckCard)
		
		var child_index: int = int(i >= DECK_CONTAINER_SPLIT_POINT[deck_slots.size()])
		DeckContainer.get_child(child_index).add_child(DeckSlotUI)
		DeckSlotUI.setDeckSlot(deck_slot)
		
		var DeckCard: CardGD = Game.onFindPublicIDObject(deck_slot.card_public_id)\
			if deck_slot.card_public_id > 0 else null
		onCreateDeckCardUI(DeckCard, DeckSlotUI)
		i += 1
		
	var stash_cards: Array = get_tree().get_nodes_in_group("StashCardsGD")
	for StashCard: CardGD in stash_cards:
		onCreateStashCardUI(StashCard)
	
func setLimitLabels() -> void:
	var energy_limit: int = Game.getSaveFile().getEnergyLimit()
	var deck_limit: int = Game.getSaveFile().getDeckLimit()
	
	var used_energy_limit: int = Game.getSaveFile().getDecksTotalEnergy()
	var used_deck_slots: int = Game.getSaveFile().getUsedDeckSlotCount()
	
	DeckLimitLabel.text = str(used_deck_slots) + "/" + str(deck_limit)
	EnergyLimitLabel.text = str(used_energy_limit) + "/" + str(energy_limit)
	
var is_mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
	is_mouse_in_ui = state

func onExitButtonPressed() -> void:
	exit_start.emit()
	AniPlayer.play_backwards("SlideUIElements")
	FadeCreamBackground.onFade(false)
	await AniPlayer.animation_finished
	queue_free()

func onSlotLocked(deck_slot: DeckSlot, state: bool) -> void:
	deck_slot.is_locked = state
	
func onSendToStash(deck_slot: DeckSlot, Card: CardGD) -> void:
	deck_slot.card_public_id = 0
	onCreateStashCardUI(Card)
	deck_slot_changed.emit()
	
var deck_slot_selected: DeckSlot
func onDeckSlotPressed(deck_slot: DeckSlot, selected: bool) -> void:
	for StashCardUI: Control in StashContainer.get_children():
		StashCardUI.setHighlightOnHover(selected)
	
	if !selected:
		for DeckSlotUI: Control in getDeckContainerDeckUI():
			if DeckSlotUI.deck_slot == deck_slot_selected and DeckSlotUI.selected:
				DeckSlotUI.onSelect(false)
		deck_slot_selected = null
		return
	
	for DeckSlotUI: Control in getDeckContainerDeckUI():
		if DeckSlotUI.deck_slot != deck_slot and DeckSlotUI.selected:
			DeckSlotUI.onSelect(false)
		
	deck_slot_selected = deck_slot
	
func getDeckContainerCardUI() -> Array:
	return getDeckContainerDeckUI().map(func(x: Control): return x.CardUI)
	
func getDeckContainerDeckUI() -> Array:
	var deck_uis: Array = []
	for cont: Container in DeckContainer.get_children():
		deck_uis += cont.get_children()
	return deck_uis
	
func onRemoveDeckCard(_CardUI: Control, _deck_slot: DeckSlot) -> void:
	setLimitLabels()
	onDeckSlotPressed(deck_slot_selected, false)

func onStashCardPressed(CardUI: Control) -> void:
	if deck_slot_selected == null: return
	
	var card_public_id: int = deck_slot_selected.card_public_id
	var DeckSlotCard: CardGD = Game.onFindPublicIDObject(card_public_id) if card_public_id > 0 else null
	
	var replace_card_energy: int = 0 if DeckSlotCard == null else DeckSlotCard.energy
	if (Game.getSaveFile().getDecksTotalEnergy() + CardUI.Card.energy - replace_card_energy) > Game.getSaveFile().getEnergyLimit():
		if AniPlayer.is_playing(): return
		
		AniPlayer.play("EnergyLimitReached")
		return
		
	for StashCardUI: Control in StashContainer.get_children():
		StashCardUI.setHighlightOnHover(false)
	
	var Card: CardGD = CardUI.Card
	CardUI.queue_free()
	
	if DeckSlotCard != null:
		onCreateStashCardUI(DeckSlotCard)
	
	deck_slot_selected.onAddCard(Card)
	
	for DeckSlotUI: Control in getDeckContainerDeckUI():
		if DeckSlotUI.deck_slot == deck_slot_selected:
			onCreateDeckCardUI(Card, DeckSlotUI)
			DeckSlotUI.onSelect(false)
			
	deck_slot_selected = null
	setLimitLabels()
	
	deck_slot_changed.emit()

func onCreateStashCardUI(StashCard: CardGD) -> void:
	var CardUI: Control = StashCard.onCreateCardUI(StashContainer, false, false)
	CardUI.pressed.connect(onStashCardPressed)
	CardUI.mouse_in_ui.connect(onMouseInUI)
	CardUI.setDraggableTool(true)
	CardUI.tool_drag_begin.connect(onToolDragBegin)
	CardUI.tool_drag_end.connect(onToolDragEnd)
	
func onCreateDeckCardUI(DeckCard: CardGD, DeckSlotUI: Control) -> void:
	var CardUI: Control
	if DeckCard != null:
		CardUI = DeckCard.onCreateCardUI(DeckSlotUI, false, false)
		if CardUI != null:
			CardUI.mouse_in_ui.connect(onMouseInUI)
			CardUI.onChangeBackgroundMouseFilter(false, true)
			CardUI.setDraggableTool(true)
			CardUI.tool_drag_begin.connect(onToolDragBegin)
			CardUI.tool_drag_end.connect(onToolDragEnd)
	DeckSlotUI.setCardUI(CardUI)
	
func onToolDragBegin(CardUI: Control) -> void:
	
	onDeckSlotPressed(null, false)
	var deck_container_card_ui: Array = getDeckContainerCardUI()
	for OtherCardUI: Control in (StashContainer.get_children() + deck_container_card_ui)\
		.filter(func(x: Control): return x != null and x != CardUI):
		OtherCardUI.setHighlightOnHover(true)
	
	for OtherCardUI: Control in deck_container_card_ui\
		.filter(func(x: Control): return x != null and x != CardUI):
		OtherCardUI.onChangeBackgroundMouseFilter(true, true)
	
func onToolDragEnd(CardUI: Control, tool_position: Vector2) -> void:
	var deck_container_card_ui: Array = getDeckContainerCardUI()
	for OtherCardUI: Control in (StashContainer.get_children() + deck_container_card_ui)\
		.filter(func(x: Control): return x != null and x != CardUI):
		OtherCardUI.setHighlightOnHover(false)
		
	for OtherCardUI: Control in deck_container_card_ui\
		.filter(func(x: Control): return x != null and x != CardUI):
		OtherCardUI.onChangeBackgroundMouseFilter(false, true)
		
	get_viewport().update_mouse_cursor_state()
		
	CardUIRaycast.global_position = tool_position
	CardUIRaycast.target_position = Vector2.ZERO
	CardUIRaycast.force_raycast_update()
	var area: Area2D = CardUIRaycast.get_collider()
	if area == null: return
	var OtherCardUI: Control = area.get_parent()
	if CardUI == OtherCardUI: return
	
	var Card: CardGD = CardUI.Card
	var OtherCard: CardGD = OtherCardUI.Card
	var actions: Array = []
	var FirstTool: ToolGD = Card.getTool()
	var SecondTool: ToolGD = OtherCard.getTool()
	
	if SecondTool == null:
		actions.append(RemoveToolAction.new(Card, true))
		actions.append(AddToolAction.new(OtherCard, FirstTool))
	elif FirstTool.info.id == SecondTool.info.id and !FirstTool.getAscended() and !SecondTool.getAscended():
		actions.append(RemoveToolAction.new(Card, false))
		actions.append(AscendToolAction.new(SecondTool, true))
		FirstTool = null
	else:
		actions.append(RemoveToolAction.new(Card, true))
		actions.append(RemoveToolAction.new(OtherCard, true))
		actions.append(AddToolAction.new(Card, SecondTool))
		actions.append(AddToolAction.new(OtherCard, FirstTool))
		
	for action: Action in actions:
		Game.getArea().onForceAction(action)

	if FirstTool != null:
		OtherCardUI.onToolUpdated(FirstTool)
		CardUI.onToolUpdated(SecondTool)
	else: # Ascenscion happened
		OtherCardUI.onToolUpdated(SecondTool)
		CardUI.onToolUpdated(FirstTool)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ScrollUp"):
		onScroll(-1)
	elif Input.is_action_just_pressed("ScrollDown"):
		onScroll(1)
		
const SCROLL_STRENGTH: int = 200
const SCROLL_SPEED: float = 0.1

func onScroll(direction: int) -> void:
	var scroll_cont: ScrollContainer = BoonScrollContainer if BoonBox.is_mouse_in_ui else MainScrollContainer
	var tween := create_tween()
	tween.tween_property(scroll_cont, "scroll_vertical", SCROLL_STRENGTH * direction, SCROLL_SPEED).as_relative().set_trans(Tween.TRANS_SINE)
