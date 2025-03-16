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
	var BossCard: EpicCardGD = Game.getLevel().getBoss()
	BossCard.setBossIntent(boss_intent)
