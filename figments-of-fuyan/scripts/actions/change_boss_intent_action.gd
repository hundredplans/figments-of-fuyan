class_name ChangeBossIntentAction extends Action

const DEFAULT_DELAY: float = 1.5
var boss_intent: BossIntent
func _init(_boss_intent: BossIntent = null) -> void:
	super()
	boss_intent = _boss_intent
	
func onPreAction() -> void:
	var BossCard: CardGD = Game.getLevel().getBoss()
	if BossCard != null and BossCard.isLevelVisible():
		setActionDelay(DEFAULT_DELAY)
	
func onPostAction() -> void:
	var BossCard: BossCardGD = Game.getLevel().getBoss()
	BossCard.setBossIntent(boss_intent)
	BossCard.boss_datastore.boss_intent_name_to_cooldown[boss_intent.name] = boss_intent.default_cooldown if BossCard.isLevelVisible() else 0
