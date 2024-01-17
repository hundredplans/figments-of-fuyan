class_name BaseCardsGD
extends Node

func predicate_by_property(id: int, property: String, value: int, operation: String) -> bool:
	var base_card: Dictionary = Helper.id_to_dict(id, "Card") #consider making a dictionary at runtime
	if !base_card.is_empty():
		match operation:
			"==": return base_card[property] == value
	return false
