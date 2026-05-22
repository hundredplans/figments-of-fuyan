extends FieldEffectGD

const SHIELD_ID: int = 3
const BOUNCY_SHIELD_ID: int = 20

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is RemoveFieldEffectAction and action.FieldEffect != null and action.FieldEffect.info.id == SHIELD_ID and action.FieldEffect.Card == Card:
			onPushAction(FieldEffectActivatedAction.new(self, action))
	
func onFieldEffectAdded(is_init: bool) -> void:
	super(is_init)
	if is_init:
		Card.onGainShield(self)

func onFieldEffect(_action: Action) -> void:
	var enemy_cards: Array = Game.getAllyUnits(1)
	enemy_cards = enemy_cards.filter(func(x: CardGD): return x != Card and x.getHealth() > 1 and x.getFirstFieldEffect(BOUNCY_SHIELD_ID) == null)
	onPushAction(RemoveFieldEffectAction.new(self))
	if enemy_cards.is_empty(): return
	var EnemyCard: CardGD = enemy_cards.pick_random()
	EnemyCard.onCreateBaseFieldEffect(BOUNCY_SHIELD_ID)
