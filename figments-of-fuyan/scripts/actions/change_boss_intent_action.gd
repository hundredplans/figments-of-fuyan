class_name ChangeBossIntentAction extends Action

const DEFAULT_DELAY: float = 1.5
var boss_intent: BossIntent
var delay_override: bool
func _init(_boss_intent: BossIntent = null, _delay_override: bool = false) -> void:
	super()
	boss_intent = _boss_intent
	delay_override = _delay_override
	
func onPreAction() -> void:
	var BossCard: CardGD = Game.getLevel().getBoss()
	if !delay_override and BossCard != null and BossCard.isLevelVisible():
		setActionDelay(DEFAULT_DELAY)
	
func onPostAction() -> void:
	var BossCard: EpicCardGD = Game.getLevel().getBoss()
	BossCard.setBossIntent(boss_intent)
	BossCard.boss_datastore.setIntentDuration(boss_intent.duration)
	
	BossCard.onFirstUpdateBossIntent()
