class_name AttackAction extends Action

var Attacker: GameObjectGD
var Defenders: Array

func _init(_Attacker: GameObjectGD = null, _Defenders: Variant = null) -> void:
	super()
	Attacker = _Attacker
	
	if _Defenders is Array: Defenders = _Defenders
	elif _Defenders is GameObjectGD: Defenders = [_Defenders]
	
func onPreAction() -> void:
	setActionDelay(1.25 if Attacker.isLevelVisible() or Defenders.any(func(x: GameObjectGD): return x.isLevelVisible()) else 0.0)
	onForceAction(ChangeAttacksAction.new(Attacker, Attacker.attacks - 1))
	
func onPostAction() -> void:
	onForceAction(ChangeTileRotationAction.new(Attacker, Game.getRelativeTileRotation(Attacker.Tile, Defenders[0].getAttackableTile())))
	for Defender in Defenders.filter(func(x: GameObjectGD): return x is CardGD):
		onForceAction(ChangeTileRotationAction.new(Defender, Game.getRelativeTileRotation(Defender.Tile, Attacker.Tile)))
	Attacker.onAttack()
	
	var actions: Array = []
	if Attacker is CardGD:
		actions.append(StatAction.new(StatInfo.new(Attacker, Game.Stats.SPEED, 0, 0, true, false, true)))
		
	actions.append(DamageAction.new(Attacker, Defenders, Attacker.getAttackDamage()))
	onPushAction(actions)
