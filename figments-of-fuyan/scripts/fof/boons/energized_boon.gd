
extends BoonGD

var cards: Array = []
const ENERGIZED_BOON_FIELD_EFFECT_ID: int = 9

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is AwakenAction and action.Card.isAlly(0):
			onPushAction(BoonActivatedAction.new(self, action))
	
func onAscend(state: bool) -> void:
	super(state)

func getDescription() -> String:
	return super()

func onBoon(action: Action = null) -> void:
	var speed: int = 1 if !ascended else 2
	var turns: int = 2 if !Game.isChampion(action.Card.info.rarity) else 1
	onPushAction(StatAction.new(StatInfo.new(action.Card, Game.Stats.MAX_SPEED, speed, turns)))
	
	var FieldEffect: FieldEffectGD = action.Card.onCreateBaseFieldEffect(ENERGIZED_BOON_FIELD_EFFECT_ID)
	cards.append(action.Card)

func onBoonAdded() -> void:
	pass

func onSave() -> SavedDataBoon:
	ability_save['cards'] = cards.map(func(x: CardGD): return x.public_id)
	return super()
	
func onLoadData(data: SavedData) -> void:
	super(data)
	cards = cards.map(func(x: int): return Game.onFindPublicIDObject(x))
	
func onLevelEnded(win: bool) -> void:
	super(win)
	cards = []
