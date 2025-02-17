class_name SpeedOrder extends Resource

var ai_speed_order: Array = []
var neutral_speed_order: Array = []

@export var ai_speed_order_public_ids: Array
@export var neutral_speed_order_public_ids: Array

var archetype_order: Dictionary = {
	Game.Archetypes.SCOUT: 11,
	Game.Archetypes.BRUTE: 10,
	Game.Archetypes.ADVENTURER: 9,
	Game.Archetypes.WARDEN: 8,
	Game.Archetypes.REINFORCER: 7,
	Game.Archetypes.TACTICIAN: 6,
	Game.Archetypes.SUPPORT: 5,
	Game.Archetypes.HOSTILE: 4,
	Game.Archetypes.ERRATIC: 3,
	Game.Archetypes.DOCILE: 2,
	Game.Archetypes.RECEIVER: 1
}

func onSave() -> void:
	ai_speed_order_public_ids = ai_speed_order.map(func(x: CardGD): return x.public_id)
	neutral_speed_order_public_ids = neutral_speed_order.map(func(x: CardGD): return x.public_id)
	
func onLoad() -> void:
	ai_speed_order = ai_speed_order_public_ids.map(func(x: int): return Game.onFindPublicIDObject(x))
	neutral_speed_order = neutral_speed_order_public_ids.map(func(x: int): return Game.onFindPublicIDObject(x))
	
func onAwaken(Card: CardGD) -> void:
	if Card.isAlly(0): return
	var order: Array = ai_speed_order if Card.isAlly(1) else neutral_speed_order
	var archetype_strength: int = archetype_order[Card.getArchetype()]
	
	# If there's any of the same archetype strength
	if order.any(func(x: CardGD): return archetype_order[x.getArchetype()] == archetype_strength):
		var same_archetype: Array = order.filter(func(x: CardGD): return archetype_order[x.getArchetype()] == archetype_strength)
		# If everyone has the same speed insert at random position
		if same_archetype.all(func(x: CardGD): return x.base_stats.speed == Card.base_stats.speed):
			same_archetype.shuffle()
			order.insert(order.find(same_archetype[0]), Card)
			return
		
		for OtherCard: CardGD in same_archetype:
			if OtherCard.base_stats.speed < Card.base_stats.speed:
				order.insert(order.find(OtherCard), Card)
				return
		
		# If it's the slowest card
		order.insert(order.find(same_archetype.size() - 1), Card)
		return
		
	for OtherCard: CardGD in order:
		if archetype_order[OtherCard.getArchetype()] < archetype_strength:
			order.insert(order.find(OtherCard), Card)
			return
			
	# If it's dead last
	order.append(Card)
	
func onDeath(Card: CardGD) -> void:
	match Card.team:
		1: ai_speed_order.erase(Card)
		2: neutral_speed_order.erase(Card)

func getNextAIUnit(inactive_cards: Array, team: int) -> CardGD:
	var order: Array = ai_speed_order if team == 1 else neutral_speed_order
	for Card in order:
		if Card in inactive_cards: return Card
	return null
