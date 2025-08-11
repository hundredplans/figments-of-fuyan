extends Control

signal active_tool_added
signal exit_start
signal deck_slot_changed
signal mouse_in_ui

var sellable: bool
var is_exit_start: bool

@export var SELL_ZONE_HAND_MAX_X: float = 100
@export var SELL_ZONE_HAND_SPEED: float = 0.5 # Lower = faster
@export var SELL_ZONE_HAND_FIRST_UPDATE_SPEED: float = 0.1
@export var SELL_ZONE_HAND_UPDATE_SPEED: float = 0.05

const SELL_ZONE_FADE_TIME: float = 0.25
const TOOL_ADDED_EXIT_DELAY: float = 1.0
const ROTATION_SPEED_TO_MIDDLE: float = 10.0
const RELATIVE_SIDE_FORCE_DIV: float = 15.0
const HAND_X_OFFSET: int = 150

var DragIconUI: TbcUI
var active_tool_released: bool
var ActiveToolIcon: Control
var sellable_rarities: Array = [Game.Rarities.COMMON, Game.Rarities.RARE, Game.Rarities.EXALT,\
	Game.Rarities.MINIBOSS, Game.Rarities.BOSS]

@export var general_shop_hands: Array[Texture2D]
@export var junk_man_hands: Array[Texture2D]

@onready var SellZoneArea: Area2D = %SellZoneArea
@onready var SellZoneHand: Sprite2D = %SellZoneHand
@onready var SellZone: Control = %SellZone

@onready var SellZoneRaycast: RayCast2D = %SellZoneRaycast
@onready var DeckSlotUIRaycast: RayCast2D = %DeckSlotUIRaycast
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

@export var ShillingsEffectPacked: PackedScene
@export var PriceLabelPacked: PackedScene
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
	var CardUI: Control = StashCard.onCreateCardUI(StashContainer, true, true, true)
	CardUI.mouse_in_ui.connect(onMouseInUI)
	var ToolIcon: TbcUI = CardUI.getToolIcon()
	ToolIcon.drag_begin.connect(onToolDragBegin.bind(CardUI))
	ToolIcon.drag_end.connect(onToolDragEnd.bind(CardUI))
	ToolIcon.setHoverable(true)
	ToolIcon.setDraggable(true)
	CardUI.drag_begin.connect(onCardDraggedBegin.bind(true))
	CardUI.drag_end.connect(onCardDraggedEnd.bind(true))
	
func onCreateDeckCardUI(DeckCard: CardGD, DeckSlotUI: Control) -> void:
	var CardUI: Control
	if DeckCard != null:
		CardUI = DeckCard.onCreateCardUI(DeckSlotUI.getCardUISpot(), true, true, true)
		if CardUI != null:
			CardUI.mouse_in_ui.connect(onMouseInUI)
			var ToolIcon: TbcUI = CardUI.getToolIcon()
			ToolIcon.drag_begin.connect(onToolDragBegin.bind(CardUI))
			ToolIcon.drag_end.connect(onToolDragEnd.bind(CardUI))
			ToolIcon.setHoverable(true)
			ToolIcon.setDraggable(true)
			CardUI.drag_begin.connect(onCardDraggedBegin.bind(false))
			CardUI.drag_end.connect(onCardDraggedEnd.bind(false))
	DeckSlotUI.setCardUI(CardUI)
	
func onToolDragBegin(ToolIcon: TbcUI, CardUI: Control) -> void:
	if ToolIcon.getItem().getRarity() in sellable_rarities and sellable:
		DragIconUI = ToolIcon
		onShowSellZone()
		onCreatePriceLabel(ToolIcon, ToolIcon.getItem())
		
	CardUI.onChangeBackgroundMouseFilter(false)
	
func onToolDragEnd(ToolIcon: TbcUI, CardUI: Control) -> void:
	if ToolIcon.getItem().getRarity() in sellable_rarities and sellable:
		DragIconUI = null
		onHideSellZone()
		ToolIcon.onRemovePriceLabel()
		
	CardUI.onChangeBackgroundMouseFilter(true)
	get_viewport().update_mouse_cursor_state()
		
	CardUIRaycast.global_position = get_viewport().get_mouse_position()
	CardUIRaycast.target_position = Vector2.ZERO
	CardUIRaycast.force_raycast_update()
	var area: Area2D = CardUIRaycast.get_collider()
	if area == null: return
	elif area == SellZoneArea: onItemSold(CardUI.ToolIcon, CardUI.getTool()); return
	
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
	elif FirstTool.info.id == SecondTool.info.id and FirstTool.getTier() == SecondTool.getTier() and FirstTool.getTier() != Game.MAX_TOOL_TIER:
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
	if BoonIcon.Boon.getRarity() in sellable_rarities and sellable:
		DragIconUI = BoonIcon
		onShowSellZone()
		onCreatePriceLabel(BoonIcon, BoonIcon.Boon)
	
func onBoonDragEnd(BoonIcon: Control) -> void:
	if BoonIcon.Boon.getRarity() in sellable_rarities and sellable:
		DragIconUI = null
		onHideSellZone()
		BoonIcon.onRemovePriceLabel()
		
	SellZoneRaycast.global_position = get_viewport().get_mouse_position()
	SellZoneRaycast.target_position = Vector2.ZERO
	SellZoneRaycast.force_raycast_update()
	var area: Area2D = SellZoneRaycast.get_collider()
	if area == null: return
	if area == SellZoneArea and sellable:
		onItemSold(BoonIcon, BoonIcon.getItem())

func onCreatePriceLabel(IconUI: Control, item: FofGD) -> void:
	var PriceLabel: Control = PriceLabelPacked.instantiate()
	IconUI.onAddPriceLabel(PriceLabel)
	var sh: int = int(float(Game.getPriceForItem(item)) * Game.SELL_MULT)
	PriceLabel.setShillings(sh)

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
	var DupeTool: ToolGD = SavedData.onLoadModel(Tool.getDuplicateData(), Game.getSaveFile())
	
	Card.onForceAction(AddToolAction.new(Card, DupeTool, true))
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
	StashContainer.queue_sort()
	if CardUI.Card.getRarity() in sellable_rarities and sellable:
		DragIconUI = CardUI
		onShowSellZone()
		onCreatePriceLabel(CardUI, CardUI.Card)
		
	var ExcludeDeckSlotUI: Control = null if is_stash_card else getDeckSlotUIFromCardUI(CardUI)
	CardUI.onChangeBackgroundMouseFilter(false)
	for DeckSlotUI: Control in getDeckContainerDeckUI():
		if DeckSlotUI != ExcludeDeckSlotUI:
			DeckSlotUI.setBackgroundMouseFilter(Control.MOUSE_FILTER_STOP)
			DeckSlotUI.setLockMouseFilter(Control.MOUSE_FILTER_IGNORE)
			
	for StashCardUI: Control in getStashCardsUI():
		StashCardUI.onChangeBackgroundMouseFilter(false)
		
	for DeckCardUI: Control in getDeckContainerCardUI().filter(func(x: Control): return x != null):
		DeckCardUI.onChangeBackgroundMouseFilter(false)

	setSellZoneHandPosition()

func onCardDraggedEnd(CardUI: Control, is_stash_card: bool) -> void:
	if CardUI.Card.getRarity() in sellable_rarities and sellable:
		DragIconUI = null
		onHideSellZone()
		CardUI.onRemovePriceLabel()
	
	for DeckSlotUI: Control in getDeckContainerDeckUI():
		DeckSlotUI.setBackgroundMouseFilter(Control.MOUSE_FILTER_IGNORE)
		DeckSlotUI.setLockMouseFilter(Control.MOUSE_FILTER_STOP)
	
	for StashCardUI: Control in getStashCardsUI():
		StashCardUI.onChangeBackgroundMouseFilter(true)
		
	for DeckCardUI: Control in getDeckContainerCardUI().filter(func(x: Control): return x != null):
		DeckCardUI.onChangeBackgroundMouseFilter(true)
		
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
	elif area == SellZoneArea:
		onItemSold(CardUI, CardUI.Card)
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

func onStashIsSellable() -> void:
	sellable = true
	SellZoneHand.visible = true
	
	for BoonIcon: Control in BoonBox.get_children():
		BoonIcon.setDraggable(true)
		BoonIcon.setHoverable(true)
		BoonIcon.drag_begin.connect(onBoonDragBegin)
		BoonIcon.drag_end.connect(onBoonDragEnd)
		
	SellZoneHand.texture = getHandTexture(false)

var SellZoneTween: Tween
func onShowSellZone() -> void:
	if !sellable: return
	if SellZoneTween: SellZoneTween.kill()
	SellZoneTween = create_tween()
	SellZoneTween.tween_property(SellZone, "modulate:a", 1.0, SELL_ZONE_FADE_TIME)
	setSellZoneHandPosition()
	
func onHideSellZone() -> void:
	if !sellable: return
	if SellZoneTween: SellZoneTween.kill()
	SellZoneTween = create_tween()
	SellZoneTween.tween_property(SellZone, "modulate:a", 0.0, SELL_ZONE_FADE_TIME)

func onItemSold(ItemUI: Control, item: FofGD) -> void:
	if !sellable: return
	if item.getRarity() not in sellable_rarities: return
	ItemUI.setIgnoreDragPositionReset(true)
	var price: int = int(float(Game.getPriceForItem(item)) * Game.SELL_MULT)
	await onItemSoldVisual(ItemUI, item, price)
	Game.getSaveFile().onPushAction(ChangeShillingsAction.new(price))
	
	if item is CardGD:
		var deck_slot: DeckSlot = getDeckSlotFromCardUI(ItemUI)
		if deck_slot == null: return # Stash card sold
		onRemoveDeckCard(ItemUI, deck_slot, false)
	elif item is BoonGD:
		Game.getSaveFile().onPushAction(RemoveBoonAction.new(item.info.id))
	elif item is ToolGD:
		var Card: CardGD = item.getCard()
		Game.getSaveFile().onPushAction(RemoveToolAction.new(Card))
		var card_uis: Array = (getStashCardsUI() + getDeckContainerCardUI())\
			.filter(func(x: TbcUI): return x != null)
		var CardUI: TbcUI = card_uis.filter(func(x: TbcUI): return x.getCard() == Card)[0]
		CardUI.onToolUpdated(null)

func onItemSoldVisual(ItemUI: Control, item: FofGD, price: int) -> void:
	ItemUI.onDisableDraggable()
	ItemUI.setMouseFilter(Control.MOUSE_FILTER_IGNORE)
	
	var initial_hand_position: Vector2 = SellZoneHand.global_position
	var item_center: Vector2 = ItemUI.global_position + ItemUI.pivot_offset
	
	if HandPositionTween: HandPositionTween.kill()
	HandPositionTween = create_tween()
	
	var first_position: Vector2 = (item_center - SellZoneHand.global_position) + Vector2(HAND_X_OFFSET, 0)
	var second_position: Vector2 = SellZoneHand.global_position + first_position + Vector2(500, 0)
	var third_position: Vector2 = initial_hand_position - second_position
	
	HandPositionTween.tween_property(SellZoneHand, "global_position", first_position, SELL_ZONE_HAND_SPEED)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	HandPositionTween.tween_property(SellZoneHand, "global_position", Vector2(500, 0), SELL_ZONE_HAND_SPEED)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	HandPositionTween.tween_property(SellZoneHand, "global_position", third_position, SELL_ZONE_HAND_SPEED)\
		.as_relative().set_trans(Tween.TRANS_SINE)
		
	await get_tree().create_timer(SELL_ZONE_HAND_SPEED).timeout
	SellZoneHand.texture = getHandTexture(true)
		
	var ShillingsEffect: Control = ShillingsEffectPacked.instantiate()
	add_child(ShillingsEffect)
	ShillingsEffect.setInfo(price, item_center)
		
	var tween := create_tween()
	tween.tween_property(ItemUI, "global_position", Vector2(500, 0), SELL_ZONE_HAND_SPEED)\
		.as_relative().set_trans(Tween.TRANS_SINE)
	
	await get_tree().create_timer(SELL_ZONE_HAND_SPEED).timeout
	SellZoneHand.texture = getHandTexture(false)
	
	if item is BoonGD or item is CardGD: # Tool don't get queue'd
		ItemUI.queue_free()

var HandPositionTween: Tween
func setSellZoneHandPosition(is_first: bool = true) -> void:
	if DragIconUI == null: return
	if HandPositionTween: HandPositionTween.kill()
	HandPositionTween = create_tween()
	
	var update_speed: float = SELL_ZONE_HAND_UPDATE_SPEED
	if is_first:
		SellZoneHand.texture = getHandTexture(false)
		update_speed = SELL_ZONE_HAND_FIRST_UPDATE_SPEED
		
	HandPositionTween.tween_property(SellZoneHand, "position", getHandUpdatedPosition() - SellZoneHand.position,\
		update_speed).as_relative().set_trans(Tween.TRANS_SINE) 
		
	await HandPositionTween.finished
	setSellZoneHandPosition(false)
	
func getHandUpdatedPosition() -> Vector2:
	var center: Vector2 = get_viewport().get_mouse_position()
	var x: int = abs((SELL_ZONE_HAND_MAX_X * (center.x / 1920.0)) - SELL_ZONE_HAND_MAX_X)
	var y: int = clamp(center.y, SellZone.global_position.y, SellZone.global_position.y + SellZone.size.y)
	return Vector2(x + 2000, y)

func getHandTexture(is_closed: bool = false) -> Texture2D:
	var arr: Array[Texture2D] = []
	match Game.getArea().getEnteredMapNode().info.id:
		6: arr = general_shop_hands
		12: arr = junk_man_hands
	if arr.is_empty(): return null
	return arr[int(is_closed)]
