class_name HealAction extends Action

var cards: Array
var heals: Array

func _init(_cards: Variant = null, _heals: Variant = null) -> void:
	super()
	if _cards is CardGD: cards = [_cards]
	else: cards = _cards
	
	if _heals is int: heals = [_heals]
	else:
		heals = _heals
	if heals.size() < cards.size():
		heals.resize(cards.size())
		
		for i in range(heals.size()):
			if heals[i] == null: heals[i] = heals[0]
	
func onPreAction() -> void:
	if cards.all(func(x: CardGD): return !x.isInjured()) or cards.is_empty():
		return onFailAction()
	
func onPostAction() -> void:
	var stat_infos: Array = []
	for i in range(cards.size()):
		stat_infos.append(StatInfo.new(cards[i], Game.Stats.HEALTH, heals[i]))
	onPushAction(StatAction.new(stat_infos))
