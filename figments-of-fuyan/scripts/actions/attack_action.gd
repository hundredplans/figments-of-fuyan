class_name AttackAction extends Action

var Attacker: GameObjectGD
var Defenders: Array
var delay: float

func _init(_Attacker: GameObjectGD = null, _Defenders: Variant = null) -> void:
	super()
	Attacker = _Attacker
	
	if _Defenders is Array: Defenders = _Defenders
	elif _Defenders is GameObjectGD: Defenders = [_Defenders]
	
func onPreAction() -> void:
	force_action.emit(ChangeTileRotationAction.new(Attacker, Game.getRelativeTileRotation(Attacker.Tile, Defenders[0].Tile)))
	for Defender in Defenders:
		force_action.emit(ChangeTileRotationAction.new(Defender, Game.getRelativeTileRotation(Defender.Tile, Attacker.Tile)))
	
	delay = 1.25 if Attacker.level_visible or Defenders.any(func(x: GameObjectGD): return x.level_visible) else 0.0

func onPostAction() -> void:
	Attacker.onAttack()
	
	var actions: Array = [ChangeAttacksAction.new(Attacker, Attacker.attacks - 1)]
	if Attacker is CardGD:
		actions.append(StatAction.new(StatInfo.new(Attacker, Game.Stats.SPEED, 0, 0, true)))
		
	actions.append(DamageAction.new(Attacker, Defenders, Attacker.getAttackDamage()))
	onPushAction(actions)

func getDelay() -> float:
	return delay
