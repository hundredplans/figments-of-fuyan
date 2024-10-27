extends CardGD

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidLastWill(action):
		onPushAction(LastWillAction.new(self, action))

func onLastWill(death_action: DeathAction) -> void:
	var attack_debuff: int = -1 if !ascended else -2
	var field_cards: Array = death_action.game_objects_in_vision.filter(func(x: GameObjectGD): return x is CardGD)
	var stat_infos: Array = field_cards.map(func(x: CardGD): return StatInfo.new(x, Game.Stats.ATTACK, attack_debuff, 1))
	onPushAction(StatAction.new(stat_infos))
	
