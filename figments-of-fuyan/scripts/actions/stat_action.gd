class_name StatAction extends Action

var stat_infos: Array
func _init(_stat_infos: Variant = null) -> void:
	super()
	if stat_infos != null: # Don't call when reinitialised
		if _stat_infos is Array: stat_infos = _stat_infos
		elif _stat_infos is StatInfo: stat_infos = [_stat_infos]
		
func setTurnDelay(turns: int) -> void:
	for stat_info in stat_infos:
		stat_info.turns = turns
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	var max_health_not_damage: bool
	for stat_info in stat_infos:
		var types: Array = stat_info.types
		var values: Array = stat_info.values
		var Card: CardGD = stat_info.Card
		var absolute: bool = stat_info.absolute
		var show_particles: bool = stat_info.show_particles
		var turns: int = stat_info.turns
		
		var original_types: Array = types.duplicate()
		var original_values: Array = values.duplicate()
		
		while(!types.is_empty()):
			var type: int = types.pop_front()
			var value: int = values.pop_front()
			var difference: int
			match type:
				Game.Stats.SPEED:
					var old_speed: int = Card.speed
					if stat_info.absolute: Card.speed = value
					else: Card.speed += value
					
					Card.speed = clamp(Card.speed, 0, Card.max_speed)
					difference = Card.speed - old_speed
					
				Game.Stats.MAX_SPEED:
					var old_speed: int = Card.max_speed
					if absolute: Card.max_speed = value
					else: Card.max_speed += value
					
					Card.max_speed = clamp(Card.max_speed, 1, 9)
					difference = Card.max_speed - old_speed
					
					types.append(Game.Stats.SPEED)
					values.append(value)
					
				Game.Stats.HEALTH:
					if (!absolute and value < 0) and !max_health_not_damage:
						difference = Card.onTakeDamage(owner.Damager, -value) * -1
					else:
						var old_health: int = Card.health
						Card.health = clamp(Card.health + value, 0, Card.max_health)
						difference = Card.health - old_health
						max_health_not_damage = false
						
				Game.Stats.MAX_HEALTH:
					var old_health: int = Card.max_health
					if absolute: Card.max_health = value
					else: Card.max_health += value
					
					Card.max_health = clamp(Card.max_health, 0, 99)
					difference = Card.max_health - old_health
					
					types.push_front(Game.Stats.HEALTH)
					values.push_front(value)
					max_health_not_damage = true
					
				Game.Stats.ATTACK:
					var old_attack: int = Card.attack
					if absolute: Card.attack = value
					else: Card.attack += value
					
					Card.attack = clamp(Card.attack, 0, 99)
					difference = Card.attack - old_attack
						
			if difference != 0:
				Card.onUpdateStat(type, difference, show_particles)
	
		if turns > 0:
			onPushAction(DelayedStatAction.new(
				StatInfo.new(Card, original_types, original_values.map(func(x: int): return x * -1), turns, absolute, show_particles, true)))
		Card.update_stats.emit()
	
func getLogInfo() -> Array:
	var arr: Array = []
	for stat_info in stat_infos:
		arr.append("Card: " + stat_info.Card.info.name)
		arr.append("Stat: " + str(stat_info.types.map(Game.getStatString)))
		arr.append("Value: " + str(stat_info.values))
		arr.append("Absolute: " + str(stat_info.absolute))
		arr.append("Turns: " + str(stat_info.turns))
	return arr

func hasCard(Card: CardGD) -> void:
	return stat_infos.any(func(x: StatInfo): return x.Card == Card)
	
func getCards() -> Array:
	return stat_infos.map(func(x: StatInfo): return x.Card)

func isHeal(_Card: CardGD = null) -> bool:
	for stat_info in stat_infos.filter(func(x: StatInfo): return !x.absolute and (_Card == null or x.Card == _Card)):
		for i in range(stat_info.types.size()):
			if stat_info.types[i] == Game.Stats.HEALTH and stat_info.values[i] > 0:
				return true
	return false
