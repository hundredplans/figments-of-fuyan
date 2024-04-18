class_name BaseCardsGD
extends Node

func predicate_by_property(id: int, property: String, value: int, operation: String) -> bool:
	var base_card: BaseCardGD = Helper.getCard(id)
	if base_card != null:
		match operation:
			"==": return base_card[property] == value
	return false
