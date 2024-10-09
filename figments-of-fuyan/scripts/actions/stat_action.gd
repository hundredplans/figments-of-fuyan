class_name StatAction extends Action

var GameObject: GameObjectGD
@export var game_object_coords: CoordsSaver # Can't save if an action is an owner but should be fine
@export var types: Array # Either stat or array of stats
@export var values: Array # Either value or array of values that match to types
@export var turn_delay: int # After how many turns to apply
@export var turns: int # How many turns it lasts
@export var absolute: bool # Whether it changes the stat absolutely
@export var include_action_delay: bool
@export var show_particles: bool

func _init(_GameObject: GameObjectGD = null, _type: Variant = null, _value: Variant = null, _turn_delay: int = 0, _turns: int = 0, \
	_absolute: bool = false, _include_action_delay: bool = true, _show_particles: bool = true) -> void:
	if _GameObject != null: # Avoid calling when init'd
		GameObject = _GameObject
		if _type is Game.Stats: types = [_type]
		if _value is int:
			values = [_value]
			if values.size() < types.size():
				values.resize(types.size())
				values.fill(values[0])
				
		turn_delay = _turn_delay
		turns = _turns
		absolute = _absolute
		include_action_delay = _include_action_delay
		show_particles = _show_particles
	
func onPreAction() -> void:
	if !absolute and values.all(func(x: int): return x == 0): onFailAction()
	
func onPostAction() -> void:
	for i in range(types.size()):
		var type: int = types[i]
		var value: int = values[i]
		var difference: int
		match type:
			Game.Stats.SPEED:
				var old_speed: int = GameObject.speed
				if absolute: GameObject.speed = value
				else: GameObject.speed += value
				
				GameObject.speed = clamp(GameObject.speed, 0, 99)
				difference = old_speed - GameObject.speed
				
			Game.Stats.HEALTH:
				if !absolute and value < 0: difference = GameObject.onTakeDamage(owner, -value)
		
		if difference != 0:
			GameObject.onUpdateStat(type, difference, show_particles, include_action_delay)
		
func getDelay() -> float:
	return Game.STAT_UPDATE_TIME * 2 if include_action_delay else 0.0

func onSave() -> void:
	super()
	game_object_coords = CoordsSaver.new().onSave(GameObject)
	
func onLoad() -> void:
	super()
	GameObject = game_object_coords.onLoad()
	
