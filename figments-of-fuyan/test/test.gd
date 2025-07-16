extends Node

func _ready() -> void:
	for card_info: CardInfo in Helper.getFofInfoArray(CardInfo):
		if card_info.tiers.size() < 4:
			for i: int in range(4 - card_info.tiers.size()):
				card_info.tiers.append(TierDatastore.new())
		var attack: int = card_info.attack
		var health: int = card_info.health
		var speed: int = card_info.speed
		var energy: int = card_info.energy
		var description: String = card_info.description
		
		var a_attack: int = card_info.plus_attack + attack
		var a_health: int = card_info.plus_health + health
		var a_speed: int = card_info.plus_speed + speed
		var a_energy: int = card_info.plus_energy + energy
		var a_description: String = card_info.ascended_description
		
		var tier_datastore := TierDatastore.new()
		var atier_datastore := TierDatastore.new()
		
		tier_datastore.attack = attack
		tier_datastore.health = health
		tier_datastore.speed = speed
		tier_datastore.energy = energy
		tier_datastore.description = description
		
		var active_effects: Array[ActiveEffectDatastore] = []
		for active_ability: ActiveAbilityDatastore in card_info.active_abilities:
			var active_effect := ActiveEffectDatastore.new()
			active_effect.name = active_ability.name
			active_effect.camera_type = active_ability.camera_type
			active_effect.max_charges = active_ability.max_charges
			active_effect.delay = active_ability.delay	
			active_effect.description = active_ability.description
			active_effects.append(active_effect)
		
		tier_datastore.active_abilities = active_effects
	
		atier_datastore.attack = a_attack
		atier_datastore.health = a_health
		atier_datastore.speed = a_speed
		atier_datastore.energy = a_energy
		atier_datastore.description = a_description
		
		card_info.tiers[0] = tier_datastore
		card_info.tiers[1] = atier_datastore
		ResourceSaver.save(card_info)
