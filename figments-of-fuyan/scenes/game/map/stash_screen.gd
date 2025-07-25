extends Control

signal active_tool_added
signal exit_start
signal deck_slot_changed
signal mouse_in_ui

var is_exit_start: bool

const TOOL_ADDED_EXIT_DELAY: float = 1.0
const ROTATION_SPEED_TO_MIDDLE: float = 10.0
const RELATIVE_SIDE_FORCE_DIV: float = 15.0

var active_tool_released: bool
var ActiveToolIcon: Control

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

var is_start_finished: bool
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
		
	sort_type = Game.getSaveFile().getStashSortType()
	onSortBySortType()
	
	await get_tree().create_timer(Game.FADE_TIME).timeout
	is_start_finished = true
	
func setActiveToolIcon(_ActiveToolIcon: Control) -> void:
	ActiveToolIcon = _ActiveToolIcon
	ActiveToolIcon.global_position = get_viewport().get_mouse_position() - (ActiveToolIcon.size / 2)
	ActiveToolIcon.setMouseFilter(Control.MOUSE_FILTER_IGNORE)
	
	for DeckSlotUI: Control in getDeckContainerDeckUI():
		DeckSlotUI.setMouseFilter(Control.MOUSE_FILTER_IGNORE)
	
	var deck_card_uis: Array = getDeckContainerCardUI().filter(func(x: Control): return x != null)
	for CardUI: Control in deck_card_uis:
		CardUI.onChangeBackgroundMouseFilter(true, true)
	
	for CardUI: Control in deck_card_uis + StashContainer.get_children():
		CardUI.setHighlightOnHover(true)
	
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
	is_exit_start = true
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
	onSortBySortType()
	deck_slot_changed.emit()
	
func onSortBySortType() -> void:
	match sort_type:
		1: onSortByRarity()
		2: onSortByEnergy()
		3: onSortByTier()
		4: onSortByArea()
		5: onSortByTool()
	
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
	#elif FirstTool.info.id == SecondTool.info.id and !FirstTool.getAscended() and !SecondTool.getAscended():
		#actions.append(RemoveToolAction.new(Card, false))
		#actions.append(ToolTierUpAction.new(SecondTool, true))
		#FirstTool = null
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
		
	if ActiveToolIcon != null:
		if Input.is_action_just_pressed("MainInput") and is_start_finished:
			onActiveToolIconReleased()
		if event is InputEventMouseMotion and !is_exit_start:
			ActiveToolIcon.global_position += event.relative
			ActiveToolIcon.rotation_degrees += event.relative.x / RELATIVE_SIDE_FORCE_DIV
		
func _process(delta: float) -> void:
	if ActiveToolIcon != null and !is_exit_start:
		ActiveToolIcon.rotation = lerp_angle(ActiveToolIcon.rotation, 0, ROTATION_SPEED_TO_MIDDLE * delta)
		
const SCROLL_STRENGTH: int = 200
const SCROLL_SPEED: float = 0.1

func onScroll(direction: int) -> void:
	var scroll_cont: ScrollContainer = BoonScrollContainer if BoonBox.is_mouse_in_ui else MainScrollContainer
	var tween := create_tween()
	tween.tween_property(scroll_cont, "scroll_vertical", SCROLL_STRENGTH * direction, SCROLL_SPEED).as_relative().set_trans(Tween.TRANS_SINE)

func onActiveToolIconReleased() -> void:
	CardUIRaycast.global_position = ActiveToolIcon.global_position + (ActiveToolIcon.size / 2)
	CardUIRaycast.target_position = Vector2.ZERO
	CardUIRaycast.force_raycast_update()
	ActiveToolIcon.setMouseFilter(Control.MOUSE_FILTER_STOP)
	ActiveToolIcon.rotation_degrees = 0
	
	var area: Area2D = CardUIRaycast.get_collider()
	if area == null: onExitButtonPressed(); return
	
	var CardUI: Control = area.get_parent()
	var Card: CardGD = CardUI.Card
	var Tool: ToolGD = ActiveToolIcon.Tool
	
	Card.onForceAction(AddToolAction.new(Card, Tool, true))
	CardUI.onToolUpdated(Card.Tool)
	active_tool_added.emit(CardUI)
	
	await get_tree().create_timer(TOOL_ADDED_EXIT_DELAY).timeout
	onExitButtonPressed()

var sort_type: int # 0 = nothing, 1 = rarity, 2 = energy, 3 = tier, 4 = area, 5 = tool
func onSortByRarity() -> void: # Rarity, Energy, Tier, ID
	if sort_type != 1: Game.getSaveFile().setStashSortType(1)
	sort_type = 1
	var children: Array = StashContainer.get_children()
	children.sort_custom(onSortComparatorByRarity)
	onSortStashCards(children)

func onSortByEnergy() -> void: # Energy, Rarity, Tier, ID
	if sort_type != 2: Game.getSaveFile().setStashSortType(2)
	sort_type = 2
	var children: Array = StashContainer.get_children()
	children.sort_custom(onSortComparatorByEnergy)
	onSortStashCards(children)

func onSortByTier() -> void: # Tier, Energy, Rarity, ID
	if sort_type != 3: Game.getSaveFile().setStashSortType(3)
	sort_type = 3
	var children: Array = StashContainer.get_children()
	children.sort_custom(onSortComparatorByTier)
	onSortStashCards(children)
	
var card_id_to_area_id: Dictionary[int, int] = {}
func onSortByArea() -> void: # Area, Energy, Rarity, Tier, ID
	if sort_type != 4: Game.getSaveFile().setStashSortType(4)
	sort_type = 4
	if card_id_to_area_id.is_empty():
		for area_info: AreaInfo in Helper.getFofInfoArray(AreaInfo):
			for id: int in area_info.card_ids:
				card_id_to_area_id[id] = area_info.id
	
	var children: Array = StashContainer.get_children()
	children.sort_custom(onSortComparatorByArea)
	onSortStashCards(children)
	
func onSortByTool() -> void:
	if sort_type != 5: Game.getSaveFile().setStashSortType(5)
	sort_type = 5
	var children: Array = StashContainer.get_children()
	children.sort_custom(onSortComparatorByTool)
	onSortStashCards(children)
	
func onSortComparatorByTool(xUI: Control, yUI: Control) -> bool:
	var x: CardInfo = xUI.Card.info
	var y: CardInfo = yUI.Card.info
	
	var xHasTool: bool = xUI.Card.getTool() != null
	var yHasTool: bool = yUI.Card.getTool() != null
	
	if xHasTool != yHasTool: return yHasTool
	if x.energy != y.energy: return x.energy < y.energy
	if x.rarity != y.rarity: return x.rarity < y.rarity
	if xUI.Card.getTier() != yUI.Card.getTier(): return xUI.Card.getTier() < yUI.Card.getTier()
	return x.id < y.id
	
func onSortComparatorByArea(xUI: Control, yUI: Control) -> bool:
	var x: CardInfo = xUI.Card.info
	var y: CardInfo = yUI.Card.info
	if card_id_to_area_id[x.id] != card_id_to_area_id[y.id]: return card_id_to_area_id[x.id] < card_id_to_area_id[y.id]
	if x.energy != y.energy: return x.energy < y.energy
	if x.rarity != y.rarity: return x.rarity < y.rarity
	if xUI.Card.getTier() != yUI.Card.getTier(): return xUI.Card.getTier() < yUI.Card.getTier()
	return x.id < y.id
	
func onSortComparatorByTier(xUI: Control, yUI: Control) -> bool:
	var x: CardInfo = xUI.Card.info
	var y: CardInfo = yUI.Card.info
	if xUI.Card.getTier() != yUI.Card.getTier(): return xUI.Card.getTier() < yUI.Card.getTier()
	if x.energy != y.energy: return x.energy < y.energy
	if x.rarity != y.rarity: return x.rarity < y.rarity
	return x.id < y.id
	
func onSortComparatorByRarity(xUI: Control, yUI: Control) -> bool:
	var x: CardInfo = xUI.Card.info
	var y: CardInfo = yUI.Card.info
	if x.rarity != y.rarity: return x.rarity < y.rarity
	if x.energy != y.energy: return x.energy < y.energy
	if xUI.Card.getTier() != yUI.Card.getTier(): return xUI.Card.getTier() < yUI.Card.getTier()
	return x.id < y.id
	
func onSortComparatorByEnergy(xUI: Control, yUI: Control) -> bool:
	var x: CardInfo = xUI.Card.info
	var y: CardInfo = yUI.Card.info
	if x.energy != y.energy: return x.energy < y.energy
	if x.rarity != y.rarity: return x.rarity < y.rarity
	if xUI.Card.getTier() != yUI.Card.getTier(): return xUI.Card.getTier() < yUI.Card.getTier()
	return x.id < y.id

func onSortStashCards(new_children: Array) -> void:
	new_children.reverse()
	for child: Control in StashContainer.get_children():
		StashContainer.remove_child(child)
		
	for child: Control in new_children:
		StashContainer.add_child(child)
