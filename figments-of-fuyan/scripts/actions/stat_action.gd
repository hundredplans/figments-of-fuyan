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
	for stat_info: StatInfo in stat_infos.duplicate():
		if stat_info.Card == null or !stat_info.Card.isAlive(): stat_infos.erase(stat_info)
	
	if stat_infos.is_empty(): onFailAction()
	
func onPostAction() -> void:
	for stat_info in stat_infos:
		var types: Array = stat_info.types.duplicate()
		var values: Array = stat_info.values.duplicate()
		var Card: CardGD = stat_info.Card
		var absolute: bool = stat_info.absolute
		var show_particles: bool = stat_info.show_particles
		var turns: int = stat_info.turns
		
		var new_types: Array = []
		var reverse_values: Array = []
		var i: int = 0
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
					stat_info.values[i] = difference
					
				Game.Stats.MAX_SPEED:
					var old_speed: int = Card.max_speed
					if absolute: Card.max_speed = value
					else: Card.max_speed += value
					
					Card.max_speed = clamp(Card.max_speed, 1, 9)
					difference = Card.max_speed - old_speed
					
					stat_info.types.append(Game.Stats.SPEED)
					stat_info.values.append(difference)
					
					types.append(Game.Stats.SPEED)
					values.append(value)
				Game.Stats.HEALTH:
					if (!absolute and value < 0) and owner is DamageAction:
						difference = Card.onTakeDamage(owner.Damager, -value, lock_action_delay) * -1
					else:
						var old_health: int = Card.health
						Card.health = clamp(Card.health + value, 0, Card.max_health)
						difference = Card.health - old_health
						
				Game.Stats.MAX_HEALTH:
					var old_health: int = Card.max_health
					if absolute: Card.max_health = value
					else: Card.max_health += value
					
					Card.max_health = clamp(Card.max_health, 0, 99)
					difference = Card.max_health - old_health
					
					if difference < 0:
						stat_info.types.append(Game.Stats.HEALTH)
						stat_info.values.append(value)
						
						types.append(Game.Stats.HEALTH)
						values.append(value)
				Game.Stats.ATTACK:
					var old_attack: int = Card.attack
					if absolute: Card.attack = value
					else: Card.attack += value
					
					Card.attack = clamp(Card.attack, 0, 99)
					difference = Card.attack - old_attack
									
			if difference != 0:
				Card.onUpdateStat(type, difference, show_particles)
				if turns > 0:
					new_types.append(type)
					reverse_values.append(difference * -1)
					
			i += 1
	
		if turns > 0:
			onPushAction(DelayedStatAction.new(
				StatInfo.new(Card, new_types, reverse_values, turns, absolute, show_particles, true)))
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

func hasCard(Card: CardGD) -> bool:
	return stat_infos.any(func(x: StatInfo): return x.Card == Card)
	
func getCards() -> Array:
	return stat_infos.map(func(x: StatInfo): return x.Card)
