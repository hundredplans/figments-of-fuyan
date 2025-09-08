extends Control

signal active_tool_added
signal exit_start
signal deck_slot_changed
signal mouse_in_ui

var original_tool_icon_disable_tooltip: bool

var is_junk_man: bool
var is_drag_zone: bool
var is_exit_start: bool

@export var DRAG_ZONE_HAND_MAX_X: float = 100
@export var DRAG_ZONE_HAND_SPEED: float = 0.5 # Lower = faster
@export var DRAG_ZONE_HAND_FIRST_UPDATE_SPEED: float = 0.1
@export var DRAG_ZONE_HAND_UPDATE_SPEED: float = 0.05

const JUNK_MAN_ID: int = 12
const DRAG_ZONE_FADE_TIME: float = 0.25
const TOOL_ADDED_EXIT_DELAY: float = 1.0
const ROTATION_SPEED_TO_MIDDLE: float = 10.0
const RELATIVE_SIDE_FORCE_DIV: float = 15.0
const HAND_X_OFFSET: int = 150

var map_node: MapNodeGD
var DragIconUI: TbcUI
var draggable_rarities: Array = [Game.Rarities.COMMON, Game.Rarities.RARE, Game.Rarities.EXALT,\
	Game.Rarities.MINIBOSS, Game.Rarities.BOSS]

@onready var ExitButton: Control = %ExitButton
@onready var MaxEnergyLabel: Label = %MaxEnergyLabel

@onready var DragZoneRect: ColorRect = %DragZoneRect
@onready var DragZoneLabel: Label = %DragZoneLabel
@onready var DragZoneFillBar: Control = %DragZoneFillBar
@onready var DragZoneArea: Area2D = %DragZoneArea
@onready var DragZoneHand: Sprite2D = %DragZoneHand
@onready var DragZone: Control = %DragZone

@onready var StashScreenCardUIRaycast: RayCast2D = %StashScreenCardUIRaycast
@onready var DragZoneRaycast: RayCast2D = %DragZoneRaycast
@onready var DeckSlotUIRaycast: RayCast2D = %DeckSlotUIRaycast
@onready var CardUIRaycast: RayCast2D = %CardUIRaycast
@onready var EnergyLimitLabel: Label = %EnergyLimitLabel
@onready var DeckLimitLabel: Label = %DeckLimitLabel
@onready var DeckLabel: Label = %DeckLabel
@onready var DeckContainer: Container = %DeckContainer
@onready var StashContainer: Container = %StashContainer
@onready var AniPlayer: AnimationPlayer = %AniPlayer
@onready var MainScrollContainer: Container = %MainScrollContainer
@onready var BoonScrollContainer: Container = %BoonScrollContainer

@onready var EnergyLimitTexture: TextureRect = %EnergyLimitTexture
@onready var EnergyLimitContainer: Container = %EnergyLimitContainer
@onready var FadeCreamBackground: Control = %FadeCreamBackground

@onready var BoonBox: Container = %BoonBox

@export var ShillingsEffectPacked: PackedScene
@export var PriceLabelPacked: PackedScene
@export var DeckSlotPacked: PackedScene

const DECK_SLOTS_GAP: int = 50
const DECK_SLOT_SIZE := Vector2(400, 500)
const SCROLL_TIME: float = 0.5

const DECK_CONTAINER_SPLIT_POINT: Dictionary[int, int] = { # Amount of slots to split point
	4: 4,
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
	
	MaxEnergyLabel.text = str(Game.getSaveFile().getMaxEnergy())
	
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
	
func setBackgroundColor(color: Color) -> void:
	FadeCreamBackground.color = color
	FadeCreamBackground.FADE_COLOR = color
	#DeckLabel.modulate = color
	
func setToolIcon(ToolIcon: TbcUI) -> void:
	original_tool_icon_disable_tooltip = ToolIcon.disable_tooltip
	
	ToolIcon.setDisableTooltip(true)
	ToolIcon.setDraggable(true)
	ToolIcon.setEndDragOnRelease(false)
	ToolIcon.onDragBegin()
	ToolIcon.drag_end.connect(onToolIconDragEnd)
	
	for CardUI: TbcUI in getAllCardUI():
		var _ToolIcon: TbcUI = CardUI.getToolIcon()
		_ToolIcon.setAutoscale(false)
		_ToolIcon.setHoverable(false)
		_ToolIcon.setDraggable(false)
		CardUI.setDraggable(false)
		CardUI.setAutoscale(false)
	
	for DeckSlotUI: Control in getDeckContainerDeckUI():
		DeckSlotUI.setMouseFilter(Control.MOUSE_FILTER_IGNORE)
	
	var deck_card_uis: Array = getDeckContainerCardUI().filter(func(x: Control): return x != null)
	for CardUI: Control in deck_card_uis:
		CardUI.onChangeBackgroundMouseFilter(true)
	
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
	Game.update_stash_screen.emit(false)
	await AniPlayer.animation_finished
	queue_free()

func onSlotLocked(deck_slot: DeckSlot, state: bool) -> void:
	deck_slot.is_locked = state
	
func onSendToStash(deck_slot: DeckSlot, Card: CardGD) -> void:
	onCreateStashCardUI(Card)
	onSortBySortType()
	
func onSortBySortType() -> void:
	match sort_type:
		1: onSortByRarity()
		2: onSortByEnergy()
		3: onSortByTier()
		4: onSortByArea()
		5: onSortByTool()
	
func getDeckContainerCardUI() -> Array:
	return getDeckContainerDeckUI().map(func(x: Control): return x.CardUI)
	
func getDeckContainerDeckUI() -> Array:
	var deck_uis: Array = []
	for cont: Container in DeckContainer.get_children():
		deck_uis += cont.get_children()
	return deck_uis
	
func onRemoveDeckCard(CardUI: Control, deck_slot: DeckSlot, send_to_stash: bool = true) -> void:
	var DeckSlotUI: Control = getDeckSlotDeckUI(deck_slot)
	DeckSlotUI.setCardUI(null)
	CardUI.queue_free()
	deck_slot.onRemoveCard(send_to_stash)
	
	if send_to_stash: onSendToStash(deck_slot, CardUI.Card)
	
	deck_slot_changed.emit()
	setLimitLabels()

func onStashCardHoveredDeckSlot(CardUI: Control, deck_slot: DeckSlot) -> void:
	var card_public_id: int = deck_slot.card_public_id
	var Card: CardGD = CardUI.Card
	var DeckSlotCard: CardGD = Game.onFindPublicIDObject(card_public_id) if card_public_id > 0 else null
	var DeckSlotCardUI: Control = getDeckSlotCardUI(DeckSlotCard)
	
	var replace_card_energy: int = 0 if DeckSlotCard == null else DeckSlotCard.energy
	if (Game.getSaveFile().getDecksTotalEnergy() + CardUI.Card.energy - replace_card_energy) > Game.getSaveFile().getEnergyLimit():
		if AniPlayer.is_playing(): return
		AniPlayer.play("EnergyLimitReached")
		return
	
	CardUI.queue_free()
	if DeckSlotCard != null:
		onCreateStashCardUI(DeckSlotCard)
		DeckSlotCardUI.queue_free()
	
	onCreateDeckCardUI(Card, getDeckSlotDeckUI(deck_slot))
	deck_slot.onAddCard(Card)
	setLimitLabels()
	
	deck_slot_changed.emit()
	
func onDeckCardUIHoveredDeckSlot(DeckCardUI: Control, other_deck_slot: DeckSlot) -> void:
	var current_deck_slot: DeckSlot = getDeckSlotFromCardUI(DeckCardUI)
	if current_deck_slot == other_deck_slot: return
	
	var CurrentCard: CardGD = DeckCardUI.Card
	var OtherCard: CardGD = other_deck_slot.getCard()
	
	DeckCardUI.queue_free()
	
	current_deck_slot.onRemoveCard()
	if OtherCard == null:
		other_deck_slot.onAddCard(CurrentCard)
		getDeckSlotDeckUI(current_deck_slot).setCardUI(null)
		onCreateDeckCardUI(CurrentCard, getDeckSlotDeckUI(other_deck_slot))
	else:
		var OtherCardUI: Control = getDeckSlotCardUI(OtherCard)
		
		if OtherCardUI != null:
			OtherCardUI.queue_free()
		
		other_deck_slot.onRemoveCard()
		other_deck_slot.onAddCard(CurrentCard)
		current_deck_slot.onAddCard(OtherCard)
		
		onCreateDeckCardUI(CurrentCard, getDeckSlotDeckUI(other_deck_slot))
		onCreateDeckCardUI(OtherCard, getDeckSlotDeckUI(current_deck_slot))

func onCreateStashCardUI(StashCard: CardGD) -> void:
	var CardUI: Control = StashCard.onCreateCardUI(StashContainer, true, true, true, true)
	CardUI.mouse_in_ui.connect(onMouseInUI)
	var ToolIcon: TbcUI = CardUI.getToolIcon()
	ToolIcon.drag_begin.connect(onToolDragBegin.bind(CardUI))
	ToolIcon.drag_end.connect(onToolDragEnd.bind(CardUI))
	ToolIcon.setHoverable(true)
	ToolIcon.setDraggable(true)
	ToolIcon.setAutoscale(true)
	CardUI.drag_begin.connect(onCardDraggedBegin.bind(true))
	CardUI.drag_end.connect(onCardDraggedEnd.bind(true))
	CardUI.setStashScreenCardUICollisionLayer()
	
func onCreateDeckCardUI(DeckCard: CardGD, DeckSlotUI: Control) -> void:
	var CardUI: Control
	if DeckCard != null:
		CardUI = DeckCard.onCreateCardUI(DeckSlotUI.getCardUISpot(), true, true, true, true)
		if CardUI != null:
			CardUI.mouse_in_ui.connect(onMouseInUI)
			var ToolIcon: TbcUI = CardUI.getToolIcon()
			ToolIcon.drag_begin.connect(onToolDragBegin.bind(CardUI))
			ToolIcon.drag_end.connect(onToolDragEnd.bind(CardUI))
			ToolIcon.setHoverable(true)
			ToolIcon.setDraggable(true)
			ToolIcon.setAutoscale(true)
			CardUI.drag_begin.connect(onCardDraggedBegin.bind(false))
			CardUI.drag_end.connect(onCardDraggedEnd.bind(false))
			CardUI.setStashScreenCardUICollisionLayer()
	DeckSlotUI.setCardUI(CardUI)
	
func onToolDragBegin(ToolIcon: TbcUI, CardUI: Control) -> void:
	if ToolIcon.getItem().getRarity() in draggable_rarities and is_drag_zone and !isSmithMaxTier(ToolIcon.getItem()):
		DragIconUI = ToolIcon
		onShowDragZone()
		onCreatePriceLabel(ToolIcon, ToolIcon.getItem())
		
	CardUI.onChangeBackgroundMouseFilter(false, true)
	for _CardUI: TbcUI in getAllCardUI():
		_CardUI.setAutoscale(false)
		_CardUI.setIncludeToolForHover(true)
		_CardUI.getToolIcon().setHoverable(false)
		_CardUI.getToolIcon().setAutoscale(false)
	
func onToolDragEnd(ToolIcon: TbcUI, CardUI: Control) -> void:
	if ToolIcon.getItem().getRarity() in draggable_rarities and is_drag_zone and !isSmithMaxTier(ToolIcon.getItem()):
		DragIconUI = null
		onHideDragZone()
		ToolIcon.onRemovePriceLabel()
		
	for _CardUI: TbcUI in getAllCardUI():
		_CardUI.setAutoscale(true)
		_CardUI.setIncludeToolForHover(false)
		_CardUI.getToolIcon().setHoverable(true)
		_CardUI.getToolIcon().setAutoscale(true)
		
	var OtherCardUI: TbcUI
	for _CardUI: TbcUI in getAllCardUI():
		if _CardUI.is_mouse_in_ui:
			OtherCardUI = _CardUI
	
	CardUI.onChangeBackgroundMouseFilter(true, true)
	if OtherCardUI == null:
		CardUIRaycast.global_position = get_viewport().get_mouse_position()
		CardUIRaycast.target_position = Vector2.ZERO
		CardUIRaycast.force_raycast_update()
		var area: Area2D = CardUIRaycast.get_collider()
		if area == DragZoneArea:
			onItemDragged(CardUI.ToolIcon, CardUI.getTool())
		get_viewport().update_mouse_cursor_state()
		return
		
	get_viewport().update_mouse_cursor_state()
	if CardUI == OtherCardUI: return
	
	var Card: CardGD = CardUI.Card
	var OtherCard: CardGD = OtherCardUI.Card
	var actions: Array = []
	var FirstTool: ToolGD = Card.getTool()
	var SecondTool: ToolGD = OtherCard.getTool()
	
	if SecondTool == null:
		actions.append(RemoveToolAction.new(Card, true))
		actions.append(AddToolAction.new(OtherCard, FirstTool))
	elif FirstTool.info.id == SecondTool.info.id and FirstTool.getTier() == SecondTool.getTier() and FirstTool.getTier() != Game.MAX_TIER:
		actions.append(RemoveToolAction.new(Card, false))
		actions.append(ToolRetieredAction.new(SecondTool, FirstTool.getTier() + 1))
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
		
func onBoonDragBegin(BoonIcon: Control) -> void:
	if BoonIcon.Boon.getRarity() in draggable_rarities and is_drag_zone and !isSmithMaxTier(BoonIcon.getItem()):
		DragIconUI = BoonIcon
		onShowDragZone()
		onCreatePriceLabel(BoonIcon, BoonIcon.Boon)
	
func onBoonDragEnd(BoonIcon: Control) -> void:
	if BoonIcon.Boon.getRarity() in draggable_rarities and is_drag_zone and !isSmithMaxTier(BoonIcon.getItem()):
		DragIconUI = null
		onHideDragZone()
		BoonIcon.onRemovePriceLabel()
		
	DragZoneRaycast.global_position = get_viewport().get_mouse_position()
	DragZoneRaycast.target_position = Vector2.ZERO
	DragZoneRaycast.force_raycast_update()
	var area: Area2D = DragZoneRaycast.get_collider()
	if area == null: return
	if area == DragZoneArea and is_drag_zone:
		onItemDragged(BoonIcon, BoonIcon.getItem())

func onCreatePriceLabel(IconUI: Control, item: FofGD) -> void:
	var PriceLabel: Control = PriceLabelPacked.instantiate()
	IconUI.onAddPriceLabel(PriceLabel)
	var sh: int = map_node.getStashItemPrice(item)
	PriceLabel.setShillings(sh)

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
	await tween.finished
	get_viewport().update_mouse_cursor_state()

func onToolIconDragEnd(ToolIcon: TbcUI) -> void:
	StashScreenCardUIRaycast.global_position = ToolIcon.global_position + (ToolIcon.size / 2)
	StashScreenCardUIRaycast.target_position = Vector2.ZERO
	StashScreenCardUIRaycast.force_raycast_update()
	
	ToolIcon.setDisableTooltip(original_tool_icon_disable_tooltip)
	ToolIcon.setDraggable(false)
	ToolIcon.setEndDragOnRelease(true)
	
	var area: Area2D = StashScreenCardUIRaycast.get_collider()
	if area == null: onExitButtonPressed(); return
	
	var CardUI: Control = area.get_parent()
	var Card: CardGD = CardUI.Card
	var Tool: ToolGD = ToolIcon.Tool
	var DupeTool: ToolGD = SavedData.onLoadModel(Tool.getDuplicateData(), Game.getSaveFile())
	
	Card.onForceAction(AddToolAction.new(Card, DupeTool, true))
	CardUI.onToolUpdated(Card.Tool)
	active_tool_added.emit(CardUI)
	
	for _CardUI: TbcUI in getAllCardUI():
		_CardUI.setHoverable(false)
	
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
	var x_energy: int = xUI.Card.getEnergy()
	var y_energy: int = yUI.Card.getEnergy()
	
	var xHasTool: bool = xUI.Card.getTool() != null
	var yHasTool: bool = yUI.Card.getTool() != null
	
	if xHasTool != yHasTool: return yHasTool
	if x_energy != y_energy: return x_energy < y_energy
	if x.rarity != y.rarity: return x.rarity < y.rarity
	if xUI.Card.getTier() != yUI.Card.getTier(): return xUI.Card.getTier() < yUI.Card.getTier()
	return x.id < y.id
	
func onSortComparatorByArea(xUI: Control, yUI: Control) -> bool:
	var x: CardInfo = xUI.Card.info
	var y: CardInfo = yUI.Card.info
	var x_energy: int = xUI.Card.getEnergy()
	var y_energy: int = yUI.Card.getEnergy()
	
	if card_id_to_area_id[x.id] != card_id_to_area_id[y.id]: return card_id_to_area_id[x.id] < card_id_to_area_id[y.id]
	if x_energy != y_energy: return x_energy < y_energy
	if x.rarity != y.rarity: return x.rarity < y.rarity
	if xUI.Card.getTier() != yUI.Card.getTier(): return xUI.Card.getTier() < yUI.Card.getTier()
	return x.id < y.id
	
func onSortComparatorByTier(xUI: Control, yUI: Control) -> bool:
	var x: CardInfo = xUI.Card.info
	var y: CardInfo = yUI.Card.info
	var x_energy: int = xUI.Card.getEnergy()
	var y_energy: int = yUI.Card.getEnergy()
	
	if xUI.Card.getTier() != yUI.Card.getTier(): return xUI.Card.getTier() < yUI.Card.getTier()
	if x_energy != y_energy: return x_energy < y_energy
	if x.rarity != y.rarity: return x.rarity < y.rarity
	return x.id < y.id
	
func onSortComparatorByRarity(xUI: Control, yUI: Control) -> bool:
	var x: CardInfo = xUI.Card.info
	var y: CardInfo = yUI.Card.info
	var x_energy: int = xUI.Card.getEnergy()
	var y_energy: int = yUI.Card.getEnergy()
	
	if x.rarity != y.rarity: return x.rarity < y.rarity
	if x_energy != y_energy: return x_energy < y_energy
	if xUI.Card.getTier() != yUI.Card.getTier(): return xUI.Card.getTier() < yUI.Card.getTier()
	return x.id < y.id
	
func onSortComparatorByEnergy(xUI: Control, yUI: Control) -> bool:
	var x: CardInfo = xUI.Card.info
	var y: CardInfo = yUI.Card.info
	var x_energy: int = xUI.Card.getEnergy()
	var y_energy: int = yUI.Card.getEnergy()
	
	if x_energy != y_energy: return x_energy < y_energy
	if x.rarity != y.rarity: return x.rarity < y.rarity
	if xUI.Card.getTier() != yUI.Card.getTier(): return xUI.Card.getTier() < yUI.Card.getTier()
	return x.id < y.id

func onSortStashCards(new_children: Array) -> void:
	new_children.reverse()
	for child: Control in StashContainer.get_children():
		StashContainer.remove_child(child)
		
	for child: Control in new_children:
		StashContainer.add_child(child)

func onCardDraggedBegin(CardUI: Control, is_stash_card: bool) -> void:
	if CardUI.Card.getRarity() in draggable_rarities and is_drag_zone and !isSmithMaxTier(CardUI.getItem()):
		DragIconUI = CardUI
		onShowDragZone()
		onCreatePriceLabel(CardUI, CardUI.Card)
		
	var ExcludeDeckSlotUI: Control = null if is_stash_card else getDeckSlotUIFromCardUI(CardUI)
	for DeckSlotUI: Control in getDeckContainerDeckUI():
		if DeckSlotUI != ExcludeDeckSlotUI:
			DeckSlotUI.setBackgroundMouseFilter(Control.MOUSE_FILTER_STOP)
			DeckSlotUI.setLockMouseFilter(Control.MOUSE_FILTER_IGNORE)
			
	for _CardUI: Control in getAllCardUI():
		if _CardUI == CardUI: continue
		_CardUI.onChangeBackgroundMouseFilter(false)

	setDragZoneHandPosition()

func onCardDraggedEnd(CardUI: Control, is_stash_card: bool) -> void:
	if CardUI.Card.getRarity() in draggable_rarities and is_drag_zone and !isSmithMaxTier(CardUI.getItem()):
		DragIconUI = null
		onHideDragZone()
		CardUI.onRemovePriceLabel()
	
	for DeckSlotUI: Control in getDeckContainerDeckUI():
		DeckSlotUI.setBackgroundMouseFilter(Control.MOUSE_FILTER_IGNORE)
		DeckSlotUI.setLockMouseFilter(Control.MOUSE_FILTER_STOP)
	
	for _CardUI: Control in getAllCardUI():
		if _CardUI == CardUI: continue
		_CardUI.onChangeBackgroundMouseFilter(true)
		
	DeckSlotUIRaycast.global_position = get_viewport().get_mouse_position()
	DeckSlotUIRaycast.target_position = Vector2.ZERO
	DeckSlotUIRaycast.force_raycast_update()
	var area: Area2D = DeckSlotUIRaycast.get_collider()
	if area == null: # Hovered outside
		if is_stash_card: return
		var Card: CardGD = CardUI.Card
		if Card.info.rarity == Game.Rarities.CHAMPION: return
		
		var deck_slots: Array = Game.getSaveFile().getDeckSlots()
		var deck_slot: DeckSlot = deck_slots.filter(func(x: DeckSlot):\
			return x.card_public_id == Card.public_id)[0]
		onRemoveDeckCard(CardUI, deck_slot)
	elif area == DragZoneArea:
		onItemDragged(CardUI, CardUI.Card)
	else: # Hovered inside another deck slot
		var deck_slot: DeckSlot = area.get_parent().deck_slot
		if deck_slot.is_locked: return
		
		if is_stash_card:
			onStashCardHoveredDeckSlot(CardUI, deck_slot)
		else: onDeckCardUIHoveredDeckSlot(CardUI, deck_slot)
		
func getDeckSlotCardUI(Card: CardGD) -> Control:
	for CardUI: Control in getDeckContainerCardUI().filter(func(x: Control): return x != null):
		if CardUI.Card == Card: return CardUI
	return null
	
func getDeckSlotDeckUI(deck_slot: DeckSlot) -> Control:
	for DeckSlotUI: Control in getDeckContainerDeckUI().filter(func(x: Control): return x != null):
		if DeckSlotUI.deck_slot == deck_slot: return DeckSlotUI
	return null
	
func getDeckSlotFromCardUI(CardUI: Control) -> DeckSlot:
	for DeckSlotUI: Control in getDeckContainerDeckUI():
		if DeckSlotUI.CardUI == CardUI: return DeckSlotUI.deck_slot
	return null
	
func getDeckSlotUIFromCardUI(CardUI: Control) -> Control:
	for DeckSlotUI: Control in getDeckContainerDeckUI():
		if DeckSlotUI.CardUI == CardUI: return DeckSlotUI
	return null
	
func getStashCardsUI() -> Array:
	return StashContainer.get_children()

func onActivateDragZone(_map_node: MapNodeGD) -> void:
	map_node = _map_node
	if map_node.info.id == JUNK_MAN_ID:
		DragZoneFillBar.setMaxValue(map_node.getMaxValue())
		DragZoneFillBar.setValue(map_node.getJunkManValue())
		DragZoneFillBar.onUpdateColors(map_node.getFillBarBackgroundColor(),\
			map_node.getFillBarForegroundColor())
		is_junk_man = true
	
	var enc_datastore: EncounterDatastore = map_node.getEncounterDatastore()
	DragZoneLabel.text = enc_datastore.getDragZoneName()
	DragZoneLabel.modulate = enc_datastore.getDragZoneLabelColor()
	DragZoneRect.material = enc_datastore.getDragZoneMaterial()
	DragZoneFillBar.visible = is_junk_man
	is_drag_zone = true
	DragZoneHand.visible = true
	
	for BoonIcon: Control in BoonBox.get_children():
		BoonIcon.setDraggable(true)
		BoonIcon.setHoverable(true)
		BoonIcon.drag_begin.connect(onBoonDragBegin)
		BoonIcon.drag_end.connect(onBoonDragEnd)
		
	DragZoneHand.texture = getHandTexture(false)

var DragZoneTween: Tween
func onShowDragZone() -> void:
	if !is_drag_zone: return
	if DragZoneTween: DragZoneTween.kill()
	DragZoneTween = create_tween()
	DragZoneTween.tween_property(DragZone, "modulate:a", 1.0, DRAG_ZONE_FADE_TIME)
	setDragZoneHandPosition()
	
func onHideDragZone() -> void:
	if !is_drag_zone: return
	if DragZoneTween: DragZoneTween.kill()
	DragZoneTween = create_tween()
	DragZoneTween.tween_property(DragZone, "modulate:a", 0.0, DRAG_ZONE_FADE_TIME)

func onItemDragged(ItemUI: Control, item: FofGD) -> void:
	if !is_drag_zone: return
	if item.getRarity() not in draggable_rarities: return
	elif isSmithMaxTier(item): return
	
	var price: int = map_node.getStashItemPrice(item)
	if map_node.info.id == SMITH_ID:
		if abs(price) > Game.getSaveFile().getShillings():
			onSmithFailed()
			return
	elif map_node.info.id == CRYPT_ID:
		if abs(price) > Game.getSaveFile().getShillings() or isNoValidTransformBoonsCrypt(item):
			onCryptFailed()
			return
		
	ItemUI.setDisableTooltip(true)
	Game.onEmptyTooltip(false)
	ItemUI.setIgnoreDragPositionReset(true)

	var is_exit: bool
	if is_junk_man:
		is_exit = onJunkManSell(price)
	
	ExitButton.setDisabled(true)
	await onItemDraggedVisual(ItemUI, item, price)
	if is_exit: onExitButtonPressed()
	
	Game.getSaveFile().onPushAction(ChangeShillingsAction.new(price))
			
	if map_node.isStashDragItem():
		if item is CardGD:
			var deck_slot: DeckSlot = getDeckSlotFromCardUI(ItemUI)
			if deck_slot == null:
				ItemUI.queue_free()
				item.onClear()
				return # Stash card sold
			onRemoveDeckCard(ItemUI, deck_slot, false)
		elif item is BoonGD:
			Game.getSaveFile().onPushAction(RemoveBoonAction.new(item.info.id))
		elif item is ToolGD:
			var Card: CardGD = item.getCard()
			Game.getSaveFile().onPushAction(RemoveToolAction.new(Card))
			var card_uis: Array = getAllCardUI()
			var CardUI: TbcUI = card_uis.filter(func(x: TbcUI): return x.getCard() == Card)[0]
			CardUI.onToolUpdated(null)
	elif map_node.info.id == SMITH_ID:
		ItemUI.setIgnoreDragPositionReset(false)
		ItemUI.onDragPositionReset()
	elif map_node.info.id == CRYPT_ID:
		ItemUI.setIgnoreDragPositionReset(false)
		ItemUI.onDragPositionReset()
		var energy_limit: int = Game.getSaveFile().getEnergyLimit()
		var used_energy_limit: int = Game.getSaveFile().getDecksTotalEnergy()
		if used_energy_limit > energy_limit:
			var deck_slot: DeckSlot = getDeckSlotFromCardUI(ItemUI)
			onRemoveDeckCard(ItemUI, deck_slot, true)
		setLimitLabels()
		
	ItemUI.setDisableTooltip(false)
	ItemUI.setDraggable(true)
	ItemUI.setHoverable(true)
	ItemUI.onScaleIconUISize(false, true)
	ExitButton.setDisabled(false)

func onItemDraggedVisual(ItemUI: Control, item: FofGD, price: int) -> void:
	ItemUI.setHoverable(false)
	ItemUI.setDraggable(false)
	ItemUI.setMouseFilter(Control.MOUSE_FILTER_IGNORE)
	
	var initial_hand_position: Vector2 = DragZoneHand.global_position
	var item_center: Vector2 = ItemUI.global_position + ItemUI.pivot_offset
	
	if HandPositionTween: HandPositionTween.kill()
	HandPositionTween = create_tween()
	
	var first_position: Vector2 = (item_center - DragZoneHand.global_position) + Vector2(HAND_X_OFFSET, 0)
	var second_position: Vector2 = DragZoneHand.global_position + first_position + Vector2(500, 0)
	var third_position: Vector2 = initial_hand_position - second_position
	
	HandPositionTween.tween_property(DragZoneHand, "global_position", first_position, DRAG_ZONE_HAND_SPEED)\
		.as_relative().set_trans(Tween.TRANS_SINE)
		
	if map_node.isStashDragItem():
		HandPositionTween.tween_property(DragZoneHand, "global_position", Vector2(500, 0), DRAG_ZONE_HAND_SPEED)\
			.as_relative().set_trans(Tween.TRANS_SINE)
		HandPositionTween.tween_property(DragZoneHand, "global_position", third_position, DRAG_ZONE_HAND_SPEED)\
			.as_relative().set_trans(Tween.TRANS_SINE)
		
	ItemUI.setAutoscale(false, false, false)
	await get_tree().create_timer(DRAG_ZONE_HAND_SPEED).timeout
	DragZoneHand.texture = getHandTexture(true)
		
	var ShillingsEffect: Control = ShillingsEffectPacked.instantiate()
	add_child(ShillingsEffect)
	ShillingsEffect.setInfo(price, item_center)
		
	if map_node.isStashDragItem():
		var tween := create_tween()
		tween.tween_property(ItemUI, "global_position", Vector2(500, 0), DRAG_ZONE_HAND_SPEED)\
			.as_relative().set_trans(Tween.TRANS_SINE)
			
		await get_tree().create_timer(DRAG_ZONE_HAND_SPEED).timeout
		DragZoneHand.texture = getHandTexture(false)
		if item is BoonGD or item is CardGD: # Tool don't get queue'd
			ItemUI.queue_free()
	elif map_node.info.id == SMITH_ID:
		item.onRetiered(item.getTier() + 1)
		await onSmithSuccess(ItemUI)
		if HandPositionTween: HandPositionTween.kill()
		HandPositionTween = create_tween()
		HandPositionTween.tween_property(DragZoneHand, "global_position", Vector2(500, 0), DRAG_ZONE_HAND_SPEED)\
			.as_relative().set_trans(Tween.TRANS_SINE)
		HandPositionTween.tween_property(DragZoneHand, "global_position", third_position, DRAG_ZONE_HAND_SPEED)\
			.as_relative().set_trans(Tween.TRANS_SINE)
	elif map_node.info.id == CRYPT_ID:
		await onCryptSuccessPartOne(ItemUI)
		
		var nitem: FofGD
		if item is BoonGD:
			var transform_boon_action := TransformBoonAction.new(item)
			Game.getSaveFile().onForceAction(transform_boon_action)
			nitem = transform_boon_action.getNewBoon()
		elif item is ToolGD:
			var transform_tool_action := TransformToolAction.new(item)
			Game.getSaveFile().onForceAction(transform_tool_action)
			nitem = transform_tool_action.getNewTool()
		elif item is CardGD:
			var transform_card_action := TransformCardAction.new(item, TransformCardAction.TransformType.RARITY)
			Game.getSaveFile().onForceAction(transform_card_action)
			nitem = transform_card_action.getNewCard()
			
		await onCryptSuccessPartTwo(ItemUI, nitem)
		if HandPositionTween: HandPositionTween.kill()
		HandPositionTween = create_tween()
		HandPositionTween.tween_property(DragZoneHand, "global_position", Vector2(500, 0), DRAG_ZONE_HAND_SPEED)\
			.as_relative().set_trans(Tween.TRANS_SINE)
		HandPositionTween.tween_property(DragZoneHand, "global_position", third_position, DRAG_ZONE_HAND_SPEED)\
			.as_relative().set_trans(Tween.TRANS_SINE)
		DragZoneHand.texture = getHandTexture(false)
	
	if ItemUI != null:
		ItemUI.setAutoscale(true, false, false)
	
var HandPositionTween: Tween
func setDragZoneHandPosition(is_first: bool = true) -> void:
	if DragIconUI == null: return
	if HandPositionTween: HandPositionTween.kill()
	HandPositionTween = create_tween()
	
	var update_speed: float = DRAG_ZONE_HAND_UPDATE_SPEED
	if is_first:
		DragZoneHand.texture = getHandTexture(false)
		update_speed = DRAG_ZONE_HAND_FIRST_UPDATE_SPEED
		
	HandPositionTween.tween_property(DragZoneHand, "position", getHandUpdatedPosition() - DragZoneHand.position,\
		update_speed).as_relative().set_trans(Tween.TRANS_SINE)
		
	await HandPositionTween.finished
	setDragZoneHandPosition(false)
	
func getHandUpdatedPosition() -> Vector2:
	var center: Vector2 = get_viewport().get_mouse_position()
	var x: int = abs((DRAG_ZONE_HAND_MAX_X * (center.x / 1920.0)) - DRAG_ZONE_HAND_MAX_X)
	var y: int = clamp(center.y, DragZone.global_position.y, DragZone.global_position.y + DragZone.size.y)
	return Vector2(x + 2000, y)

func getHandTexture(is_closed: bool = false) -> Texture2D:
	return Game.getArea().getEnteredMapNode().getEncounterDatastore().getHands()[int(is_closed)]

func _on_main_scroll_container_scroll_ended() -> void:
	get_viewport().update_mouse_cursor_state()

func onJunkManSell(price: int) -> bool:
	var JunkMan: MapNodeGD = Game.getArea().getEnteredMapNode()
	var max_value: int = JunkMan.getMaxValue()
	var junk_man_value: int = JunkMan.getJunkManValue() + price
	
	DragZoneFillBar.setValue(junk_man_value)
	if junk_man_value >= max_value:
		JunkMan.setJunkManValue(min(junk_man_value - max_value, max_value - 1)) # Resets
		JunkMan.onCreateRewardData()
		return true
	else: JunkMan.setJunkManValue(junk_man_value)
	return false

#region Smith
const SMITH_SWISH_TIME: float = 0.35
const SMITH_SCALE_OFFSET: float = 0.6
const SMITH_INITAL_SCALE_TIME: float = 0.2
const SMITH_RECOVERY_SCALE_TIME: float = 0.8
const SMITH_SPIN_TIME: float = 0.3
const SMITH_SPIN_TOTAL_ROTATION: float = (PI / 4)
const SMITH_ID: int = 11

func onSmithFailed() -> void:
	if HandPositionTween: HandPositionTween.kill()
	HandPositionTween = create_tween()
	
	HandPositionTween.tween_property(DragZoneHand, "global_position", Vector2(0, 100), SMITH_SWISH_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	HandPositionTween.tween_property(DragZoneHand, "global_position", Vector2(0, -100), SMITH_SWISH_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
		
func onSmithSuccess(ItemUI: TbcUI) -> void:
	var tween := create_tween()
	tween.tween_property(ItemUI, "rotation", SMITH_SPIN_TOTAL_ROTATION, SMITH_SPIN_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	tween.tween_property(ItemUI, "rotation", -SMITH_SPIN_TOTAL_ROTATION * 2, SMITH_SPIN_TIME * 2)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	tween.tween_property(ItemUI, "rotation", SMITH_SPIN_TOTAL_ROTATION, SMITH_SPIN_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
		
	var stween := create_tween()
	stween.tween_property(ItemUI, "scale", Vector2(-SMITH_SCALE_OFFSET, -SMITH_SCALE_OFFSET), SMITH_INITAL_SCALE_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	stween.tween_property(ItemUI, "scale", Vector2(SMITH_SCALE_OFFSET, SMITH_SCALE_OFFSET), SMITH_RECOVERY_SCALE_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)

	await get_tree().create_timer(DRAG_ZONE_HAND_SPEED).timeout
	DragZoneHand.texture = getHandTexture(false)
	await tween.finished
#endregion

#region Crypt
const CRYPT_ID: int = 13
const CRYPT_WAIT_TIME: float = 0.5
const CRYPT_SWISH_TIME: float = 0.35
const CRYPT_SCALE_TIME: float = 0.25

func onCryptFailed() -> void:
	if HandPositionTween: HandPositionTween.kill()
	HandPositionTween = create_tween()
	
	HandPositionTween.tween_property(DragZoneHand, "global_position", Vector2(0, 100), CRYPT_SWISH_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	HandPositionTween.tween_property(DragZoneHand, "global_position", Vector2(0, -100), CRYPT_SWISH_TIME)\
		.as_relative().set_trans(Tween.TRANS_SINE)
		
func onCryptSuccessPartOne(ItemUI: TbcUI) -> void:
	await ItemUI.onUseScaleIconUITween(0.001 - ItemUI.scale.x, CRYPT_SCALE_TIME)
		
func onCryptSuccessPartTwo(ItemUI: TbcUI, nitem: FofGD) -> void:
	ItemUI.setInfo(nitem, ItemUI.getHoverable(), ItemUI.getDraggable(), false)
	await ItemUI.onUseScaleIconUITween(1.0 - ItemUI.scale.x, CRYPT_SCALE_TIME)
	await get_tree().create_timer(CRYPT_WAIT_TIME).timeout
	
func isNoValidTransformBoonsCrypt(item: FofGD) -> bool:
	if item is not BoonGD: return false
	var Boon: BoonGD = item
	var existing_boon_ids: Array = Game.getSaveFile().getBoons().map(func(x: BoonGD): return x.info.id)
	var all: Array = Helper.getFofInfoArray(BoonInfo)
	all = all.filter(func(x: FofInfo): return x != Boon.info and x.rarity == Boon.getRarity()\
		and x.id not in existing_boon_ids)
	return all.is_empty()
	
func getAllCardUI() -> Array:
	return (getDeckContainerCardUI() + getStashCardsUI()).filter(func(x: Control): return x != null)
	
func isSmithMaxTier(item: FofGD) -> bool:
	return map_node.info.id == SMITH_ID and item.getTier() == Game.MAX_TIER
#endregion
