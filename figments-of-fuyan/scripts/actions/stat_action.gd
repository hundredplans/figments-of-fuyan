class_name StatAction extends Action

var cards: Array[CardGD] = []
var GameObject: GameObjectGD
@export var game_object_public_id: int
@export var types: Array # Either stat or array of stats
@export var values: Array # Either value or array of values that match to types
@export var turns: int # How many turns it lasts
@export var absolute: bool # Whether it changes the stat absolutely
@export var show_particles: bool

@export var is_reverse: bool # Ignores all types of buffs
@export var turn_delay: int # After how many turns to apply

func _init(_GameObject: GameObjectGD = null, _type: Variant = null, _value: Variant = null, _turns: int = 0, \
	_absolute: bool = false, _show_particles: bool = true, _is_reverse: bool = false) -> void:
	if _GameObject != null: # Avoid calling when init'd
		GameObject = _GameObject
		if _type is Game.Stats: types = [_type]
		if _value is int:
			values = [_value]
			if values.size() < types.size():
				values.resize(types.size())
				values.fill(values[0])

		turns = _turns
		absolute = _absolute

		show_particles = _show_particles
		is_reverse = _is_reverse
		
func setTurnDelay(_turn_delay: int) -> void: turn_delay = _turn_delay
	
func onPreAction() -> void:
	if !absolute and values.all(func(x: int): return x == 0): onFailAction()
	
func onPostAction() -> void:
	var max_health_not_damage: bool
	while (!types.is_empty()):
		var type: int = types.pop_front()
		var value: int = values.pop_front()
		var difference: int
		match type:
			Game.Stats.SPEED:
				var old_speed: int = GameObject.speed
				if absolute: GameObject.speed = value
				else: GameObject.speed += value
				
				GameObject.speed = clamp(GameObject.speed, 0, GameObject.max_speed)
				difference = old_speed - GameObject.speed
				
			Game.Stats.MAX_SPEED:
				var old_speed: int = GameObject.max_speed
				if absolute: GameObject.max_speed = value
				else: GameObject.max_speed += value
				
				GameObject.max_speed = clamp(GameObject.max_speed, 1, 9)
				difference = old_speed - GameObject.max_speed
				
				types.append(Game.Stats.SPEED)
				values.append(value)
				
			Game.Stats.HEALTH:
				if (!absolute and value < 0) and !max_health_not_damage:
					difference = GameObject.onTakeDamage(owner.Damager, -value) * -1
				else:
					var old_health: int = GameObject.health
					GameObject.health = clamp(GameObject.health + value, 0, GameObject.max_health)
					difference = GameObject.health - old_health
					max_health_not_damage = false
					
			Game.Stats.MAX_HEALTH:
				var old_health: int = GameObject.max_health
				if absolute: GameObject.max_health = value
				else: GameObject.max_health += value
				
				GameObject.max_health = clamp(GameObject.max_health, 0, 99)
				difference = old_health - GameObject.max_health
				
				types.push_front(Game.Stats.HEALTH)
				values.push_front(value)
				max_health_not_damage = true
				
			Game.Stats.ATTACK:
				var old_attack: int = GameObject.attack
				if absolute: GameObject.attack = value
				else: GameObject.attack += value
				
				GameObject.attack = clamp(GameObject.attack, 0, 99)
				difference = old_attack - GameObject.attack
					
		if difference != 0:
			GameObject.onUpdateStat(type, difference, show_particles)
	
	if turns > 0:
		var reverse_action: StatAction = StatAction.new(GameObject, types, values.map(func(x: int): return x * -1), 0, absolute, show_particles, true)
		onPushAction(DelayedStatAction.new(turns, reverse_action))

func onSave() -> void:
	super()
	game_object_public_id = GameObject.public_id
	
func onLoad() -> void:
	super()
	GameObject = Game.onFindPublicIDObject(game_object_public_id)
	
func onAdvanceTurn() -> void:
	turns -= 1
	if turns == 0: onPushAction(self, GameObject)
	GameObject.delayed_stats.erase(self)
	
func getLogInfo() -> Array:
	return ["Card: " + GameObject.info.name]
