class_name DeckGD
extends Node

const AFTER_PHASE_START_DRAW_COUNT: int = 3

var LevelMap: Node3D
var Heroes: HeroesGD
var BaseCards: BaseCardsGD
var Hand: HandGD
var GameState: Node

func on_create_deck() -> void:
	for card in GameState.player_deck: on_create_card(card.id, card.tool_id, card.effects)

func on_create_card(id: int, tool_id: int = 0, effects: Array = []) -> void:
	var card := DeckCardGD.new()
	card.name = str(randi())
	card.script = preload("res://scenes/screens/level_map/utility_nodes/deck/deck_card.gd")
	add_child(card)
	move_child(card, randi() % get_child_count() - 1)
	card.on_create_card(id, tool_id, effects)
	
func on_choose_champion() -> void: # make this work for multiple champions eventually
	on_force_draw_card(_get_children().filter(predicate_by_property.bind("r", 7, "=="))[0])

func predicate_by_property(deck_card: DeckCardGD, property: String, value: int, operation: String) -> bool:
	return BaseCards.predicate_by_property(deck_card.id, property, value, operation)

func on_force_draw_card(deck_card: DeckCardGD) -> void:
	Hand.on_draw_card(deck_card)
	deck_card.queue_free()

func on_draw_card() -> void:
	if _get_child_count() > 0: 
		var deck_card: DeckCardGD = _get_child(0)
		Hand.on_draw_card(deck_card)
		deck_card.queue_free()
		
		
func _get_child(i: int) -> DeckCardGD: return _get_children()[i]
func _get_children() -> Array: return get_children().filter(is_not_queued_for_deletion)
func _get_child_count() -> int: return _get_children().size()

func is_not_queued_for_deletion(deck_card: DeckCardGD) -> bool: return !deck_card.is_queued_for_deletion()

func on_after_start_phase_start() -> void:
	for i in range(AFTER_PHASE_START_DRAW_COUNT): on_draw_card()
	LevelMap.on_change_game_phase("HandPhase")
