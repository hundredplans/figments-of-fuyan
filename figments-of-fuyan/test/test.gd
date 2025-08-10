extends Node

func onTools() -> void:
	pass
	#for tool_info: ToolInfo in Helper.getFofInfoArray(ToolInfo):
		#var datastores: Array[ToolTierDatastore] = tool_info.tiers
		#datastores.pop_back()
		#
		#var tier_two_datastore: ToolTierDatastore = datastores[1]
		#var tier_three_datastore := ToolTierDatastore.new()
		#tier_three_datastore.description_datastore = tier_two_datastore.description_datastore.duplicate()
		#tier_three_datastore.active_abilities = tier_two_datastore.active_abilities.duplicate()
		#
		#var tier_four_datastore := ToolTierDatastore.new()
		#tier_four_datastore.description_datastore = tier_two_datastore.description_datastore.duplicate()
		#tier_four_datastore.active_abilities = tier_two_datastore.active_abilities.duplicate()
		#
		#datastores.append(tier_three_datastore)
		#datastores.append(tier_four_datastore)
		
		#var datastore := ToolTierDatastore.new()
		#var adatastore := ToolTierDatastore.new()
		#
		#datastore.description_datastore = DescriptionDatastore.new()
		#adatastore.description_datastore = DescriptionDatastore.new()
		#datastore.description_datastore.description = tool_info.description
		#var adescription: String = tool_info.ascended_description\
			#if !tool_info.ascended_description.is_empty() else tool_info.description
		#adatastore.description_datastore.description = adescription
		#var active_effects: Array[ActiveEffectDatastore] = []
		#for active_ability: ActiveAbilityDatastore in tool_info.active_abilities:
			#var active_effect := ActiveEffectDatastore.new()
			#active_effect.name = active_ability.name
			#active_effect.camera_type = active_ability.camera_type
			#active_effect.max_charges = active_ability.max_charges
			#active_effect.delay = active_ability.delay	
			#active_effect.description = active_ability.description
			#active_effects.append(active_effect)
		
		#datastore.active_abilities = active_effects
		#adatastore.active_abilities = active_effects.duplicate()
		#datastores.append(datastore)
		#datastores.append(adatastore)
		#datastores.append(adatastore.duplicate())
		#tool_info.tiers = datastores
		#ResourceSaver.save(tool_info)

func onBoons() -> void:
	for boon_info: BoonInfo in Helper.getFofInfoArray(BoonInfo):
		var datastores: Array[BoonTierDatastore] = boon_info.tiers
		datastores.pop_back()
		
		var tier_two_datastore: BoonTierDatastore = datastores[1]
		var tier_three_datastore := BoonTierDatastore.new()
		tier_three_datastore.description_datastore = tier_two_datastore.description_datastore.duplicate()
		
		var tier_four_datastore := BoonTierDatastore.new()
		tier_four_datastore.description_datastore = tier_two_datastore.description_datastore.duplicate()
		
		datastores.append(tier_three_datastore)
		datastores.append(tier_four_datastore)
		#var datastores: Array[BoonTierDatastore] = []
		#var datastore := BoonTierDatastore.new()
		#var adatastore := BoonTierDatastore.new()
		#datastore.description_datastore = DescriptionDatastore.new()
		#adatastore.description_datastore = DescriptionDatastore.new()
		#datastore.description_datastore.description = boon_info.description
		#var adescription: String = boon_info.ascended_description\
				#if !boon_info.ascended_description.is_empty() else boon_info.description
		#adatastore.description_datastore.description = adescription
#
		#datastores.append(datastore)
		#datastores.append(adatastore)
		#datastores.append(adatastore.duplicate())
		boon_info.tiers = datastores
		ResourceSaver.save(boon_info)

func _ready() -> void:
	pass
	#for card_info: CardInfo in Helper.getFofInfoArray(CardInfo):
		#var datastores: Array[CardTierDatastore] = card_info.tiers
		#for i in range(1, 4):
			#var datastore: CardTierDatastore = datastores[i]
			#var d: String = card_info.description if card_info.ascended_description.is_empty() else card_info.ascended_description
			#datastore.description_datastore.description = d
		
		#datastores.resize(2)
		#
		#var tier_two_datastore: CardTierDatastore = datastores[1]
		#var tier_three_datastore := CardTierDatastore.new()
		#var tier_four_datastore := CardTierDatastore.new()
		#for p: String in ["traits", "active_abilities", "description_datastore"]:
			#tier_three_datastore[p] = tier_two_datastore[p].duplicate()
			#tier_four_datastore[p] = tier_two_datastore[p].duplicate()
			#
		#for p: String in ["attack", "health", "energy", "speed"]:
			#tier_three_datastore[p] = tier_two_datastore[p]
			#tier_four_datastore[p] = tier_two_datastore[p]
		#
		#datastores.append(tier_three_datastore)
		#datastores.append(tier_four_datastore)
		#card_info.tiers = datastores
		#ResourceSaver.save(card_info)
		
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


func _on_button_pressed() -> void:
	print("It worked!")
	var original_global_position: Vector2 = %TestNode.global_position
	%TestNode.top_level = true
	%TestNode.global_position = original_global_position
