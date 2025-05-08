extends Control

signal mouse_in_ui


@onready var StashLabel: Label = %StashLabel
@onready var EnergyLimitLabel: Label = %EnergyLimitLabel
@onready var DeckLimitLabel: Label = %DeckLimitLabel
@onready var DeckContainer: Container = %DeckContainer
@onready var StashContainer: Container = %StashContainer
@onready var AniPlayer: AnimationPlayer = %AniPlayer
@onready var MainScrollContainer: Container = %MainScrollContainer

@onready var EnergyLimitTexture: TextureRect = %EnergyLimitTexture
@onready var EnergyLimitContainer: Container = %EnergyLimitContainer

@export var DeckSlotPacked: PackedScene

const DECK_SLOT_SIZE := Vector2(400, 500)
const SCROLL_TIME: float = 0.5

func setInfo() -> void:
	AniPlayer.play("SlideUIElements")
	var deck_slots: Array = Game.getSaveFile().getDeckSlots()
	setLimitLabels()
	for deck_slot: DeckSlot in deck_slots:
		var DeckSlotUI: Control = DeckSlotPacked.instantiate()
		DeckSlotUI.mouse_in_ui.connect(onMouseInUI)
		DeckSlotUI.lock_slot.connect(onSlotLocked)
		DeckSlotUI.send_to_stash.connect(onSendToStash)
		DeckSlotUI.pressed.connect(onDeckSlotPressed)
		DeckSlotUI.remove_deck_card.connect(onRemoveDeckCard)
		DeckContainer.add_child(DeckSlotUI)
		DeckSlotUI.setDeckSlot(deck_slot)
		
		var DeckCard: CardGD = Game.onFindPublicIDObject(deck_slot.card_public_id)\
			if deck_slot.card_public_id > 0 else null
		onCreateDeckCardUI(DeckCard, DeckSlotUI)
		
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
	
func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)

func onExitButtonPressed() -> void:
	AniPlayer.play_backwards("SlideUIElements")
	await AniPlayer.animation_finished
	queue_free()

func onSlotLocked(deck_slot: DeckSlot, state: bool) -> void:
	deck_slot.is_locked = state
	
func onSendToStash(deck_slot: DeckSlot, Card: CardGD) -> void:
	deck_slot.card_public_id = 0
	onCreateStashCardUI(Card)
	
var deck_slot_selected: DeckSlot
func onDeckSlotPressed(deck_slot: DeckSlot, selected: bool) -> void:
	for StashCardUI: Control in StashContainer.get_children():
		StashCardUI.setHighlightOnHover(selected)
	
	if !selected:
		deck_slot_selected = null
		return
	
	for DeckSlotUI: Control in DeckContainer.get_children():
		if DeckSlotUI.deck_slot != deck_slot and DeckSlotUI.selected:
			DeckSlotUI.onSelect(false)
		
	deck_slot_selected = deck_slot
	
func onRemoveDeckCard(_CardUI: Control, _deck_slot: DeckSlot) -> void:
	setLimitLabels()

func onStashCardPressed(CardUI: Control) -> void:
	if deck_slot_selected == null: return
	if Game.getSaveFile().getDecksTotalEnergy() + CardUI.Card.energy > Game.getSaveFile().getEnergyLimit():
		if AniPlayer.is_playing(): return
		
		AniPlayer.play("EnergyLimitReached")
		EnergyLimitTexture.reparent(self, true)
		EnergyLimitTexture.pivot_offset = EnergyLimitTexture.size / 2
		
		await AniPlayer.animation_finished
		EnergyLimitTexture.reparent(EnergyLimitContainer)
		EnergyLimitContainer.move_child(EnergyLimitTexture, 0)
		return
	
	var Card: CardGD = CardUI.Card
	CardUI.queue_free()
	
	var card_public_id: int = deck_slot_selected.card_public_id
	var DeckSlotCard: CardGD = Game.onFindPublicIDObject(card_public_id) if card_public_id > 0 else null
	if DeckSlotCard != null:
		onCreateStashCardUI(DeckSlotCard)
	
	deck_slot_selected.onAddCard(Card)
	
	for DeckSlotUI: Control in DeckContainer.get_children():
		if DeckSlotUI.deck_slot == deck_slot_selected:
			onCreateDeckCardUI(Card, DeckSlotUI)
			DeckSlotUI.onSelect(false)
			
	deck_slot_selected = null
	setLimitLabels()

func onCreateStashCardUI(StashCard: CardGD) -> void:
	var CardUI: Control = StashCard.onCreateCardUI(StashContainer, false, true)
	CardUI.pressed.connect(onStashCardPressed)
	CardUI.mouse_in_ui.connect(onMouseInUI)
	
func onCreateDeckCardUI(DeckCard: CardGD, DeckSlotUI: Control) -> void:
	var CardUI: Control
	if DeckCard != null:
		CardUI = DeckCard.onCreateCardUI(DeckSlotUI, false, true)
		if CardUI != null:
			CardUI.mouse_in_ui.connect(onMouseInUI)
			CardUI.onChangeBackgroundMouseFilter(false)
	DeckSlotUI.setCardUI(CardUI)

func setCardBoxModulate() -> void:
	pass
