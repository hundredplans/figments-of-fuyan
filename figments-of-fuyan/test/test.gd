extends Node

func onTools() -> void:
	for tool_info: ToolInfo in Helper.getFofInfoArray(ToolInfo):
		var datastores: Array[ToolTierDatastore] = []
		var datastore := ToolTierDatastore.new()
		var adatastore := ToolTierDatastore.new()
		
		datastore.description_datastore = DescriptionDatastore.new()
		adatastore.description_datastore = DescriptionDatastore.new()
		datastore.description_datastore.description = tool_info.description
		var adescription: String = tool_info.ascended_description\
			if !tool_info.ascended_description.is_empty() else tool_info.description
		adatastore.description_datastore.description = adescription
		var active_effects: Array[ActiveEffectDatastore] = []
		for active_ability: ActiveAbilityDatastore in tool_info.active_abilities:
			var active_effect := ActiveEffectDatastore.new()
			active_effect.name = active_ability.name
			active_effect.camera_type = active_ability.camera_type
			active_effect.max_charges = active_ability.max_charges
			active_effect.delay = active_ability.delay	
			active_effect.description = active_ability.description
			active_effects.append(active_effect)
		
		datastore.active_abilities = active_effects
		adatastore.active_abilities = active_effects.duplicate()
		datastores.append(datastore)
		datastores.append(adatastore)
		datastores.append(adatastore.duplicate())
		tool_info.tiers = datastores
		ResourceSaver.save(tool_info)

func onBoons() -> void:
	for boon_info: BoonInfo in Helper.getFofInfoArray(BoonInfo):
		var datastores: Array[BoonTierDatastore] = []
		var datastore := BoonTierDatastore.new()
		var adatastore := BoonTierDatastore.new()
		datastore.description_datastore = DescriptionDatastore.new()
		adatastore.description_datastore = DescriptionDatastore.new()
		datastore.description_datastore.description = boon_info.description
		var adescription: String = boon_info.ascended_description\
			if !boon_info.ascended_description.is_empty() else boon_info.description
		adatastore.description_datastore.description = adescription

		datastores.append(datastore)
		datastores.append(adatastore)
		datastores.append(adatastore.duplicate())
		boon_info.tiers = datastores
		ResourceSaver.save(boon_info)

func _ready() -> void:
	onBoons()
	#for card_info: CardInfo in Helper.getFofInfoArray(CardInfo):
		#var datastores: Array[CardTierDatastore] = []
		#
		#for tier_datastore: TierDatastore in card_info._tiers:
			#var card_tier_datastore := CardTierDatastore.new()
			#card_tier_datastore.active_abilities = tier_datastore.active_abilities
			#card_tier_datastore.description_datastore = DescriptionDatastore.new()
			#card_tier_datastore.description_datastore.description = tier_datastore.description
			#card_tier_datastore.attack = tier_datastore.attack
			#card_tier_datastore.health = tier_datastore.health
			#card_tier_datastore.speed = tier_datastore.speed
			#card_tier_datastore.energy = tier_datastore.energy
			#card_tier_datastore.traits = tier_datastore.traits
			#datastores.append(card_tier_datastore)
		#card_info._tiers = card_info.tiers.duplicate()
		#card_info.tiers = datastores
		#ResourceSaver.save(card_info)
			
		#if card_info.tiers.size() < 4:
			#for i: int in range(4 - card_info.tiers.size()):
				#card_info.tiers.append(TierDatastore.new())
		#var attack: int = card_info.attack
		#var health: int = card_info.health
		#var speed: int = card_info.speed
		#var energy: int = card_info.energy
		#var description: String = card_info.description
		#
		#var a_attack: int = card_info.plus_attack + attack
		#var a_health: int = card_info.plus_health + health
		#var a_speed: int = card_info.plus_speed + speed
		#var a_energy: int = card_info.plus_energy + energy
		#var a_description: String = card_info.ascended_description
		#
		#var tier_datastore := TierDatastore.new()
		#var atier_datastore := TierDatastore.new()
		#
		#tier_datastore.attack = attack
		#tier_datastore.health = health
		#tier_datastore.speed = speed
		#tier_datastore.energy = energy
		#tier_datastore.description = description
		#
		#var active_effects: Array[ActiveEffectDatastore] = []
		#for active_ability: ActiveAbilityDatastore in card_info.active_abilities:
			#var active_effect := ActiveEffectDatastore.new()
			#active_effect.name = active_ability.name
			#active_effect.camera_type = active_ability.camera_type
			#active_effect.max_charges = active_ability.max_charges
			#active_effect.delay = active_ability.delay	
			#active_effect.description = active_ability.description
			#active_effects.append(active_effect)
		#
		#tier_datastore.active_abilities = active_effects
	#
		#atier_datastore.attack = a_attack
		#atier_datastore.health = a_health
		#atier_datastore.speed = a_speed
		#atier_datastore.energy = a_energy
		#atier_datastore.description = a_description
		#
		#card_info.tiers[0] = tier_datastore
		#card_info.tiers[1] = atier_datastore
		#ResourceSaver.save(card_info)
