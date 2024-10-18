extends CardGD

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidLastWill(action):
		onPushAction(LastWillAction.new(self, action))

func onLastWill(death_action: DeathAction) -> void:
	var attack_debuff: int = -1 if !ascended else -2
	var actions: Array = []
	for FieldCard in death_action.game_objects_in_vision.filter(func(x: GameObjectGD): return x is CardGD):
		actions.append(StatAction.new(FieldCard, Game.Stats.ATTACK, attack_debuff))
	onPushAction(actions)
	
