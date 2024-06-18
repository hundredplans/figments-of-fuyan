class_name DeathActionGD
extends ActionGD

const type: int = ActionManagerGD.DEATH
var AppliedBy: AppliedByGD

func _init(_Unit: UnitGD = null, _AppliedBy: AppliedByGD = null, _is_visible: bool = true, _delay: DelayGD = null) -> void:
	Unit = _Unit
	AppliedBy = _AppliedBy
	delay = _delay
	is_visible = _is_visible
	if delay == null: delay = DelayGD.new(2.0)
	super()
	
func onTrigger() -> void:
	Unit.Model.on_death()
	StatusManager.onDeathBegin(Unit, delay.delay)

func onAfterTrigger() -> void:
	SpectateCamera.onStopTrack()
	await Unit.on_death()
	StatusManager.onDeathFinished(Unit)
	Hand.onGainDeathEnergy(Unit, AppliedBy)
	AIManager.onDeathFinished(Unit)
	onCalculateWinState()

func onCalculateWinState() -> void:
	var win_state: int = 0
	if Units.on_units(TeamRelationGD.new(1)).is_empty(): win_state = 1
	if Units.on_units().is_empty(): win_state = 2
	
	var dev := preload("res://static/dev/dev.tres")
	if !dev.win_enabled: win_state = 0
	match win_state:
		0: 
			Vision.onDeathFinished(Unit)
			Combat.onDeathAbilities(Unit, AppliedBy)
			PlayerManager.onDeathFinished(Unit, AppliedBy)
			GameEffects.onDeathFinished(Unit)
			ActionManager.onDeath(Unit)
		1: LevelUI.onWinGame()
		2: LevelUI.onLoseGame()
