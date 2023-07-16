extends Node2D
	
func on_DeckManagerDoubleDecker(cards: Array):
	var xoffset: float = -7.2
	var ypos: float = -2.2
	var zpos: float = -6.45 # -6.5
	for card in cards:
		if ypos == -2.2: ypos = 1
		else: ypos = -2.2
		card.position = Vector3(xoffset, ypos, zpos)
		if ypos == -2.2: xoffset += 2
func send_sort_cards(cards: Array, sort: Dictionary):
	for card in cards: $CardViewport/Cards.add_child(card)
	match sort.sort_type:
		"DeckManagerDoubleDecker": on_DeckManagerDoubleDecker(cards)
func clear_cards(): for child in $CardViewport/Cards.get_children(): child.queue_free()
