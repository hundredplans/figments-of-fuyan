class_name AttackAction extends Action

var Attacker: GameObjectGD
var Defender: GameObjectGD

func _init(_Attacker: GameObjectGD = null, _Defender: GameObjectGD = null) -> void:
	super()
	Attacker = _Attacker
	Defender = _Defender
	
func onPreAction() -> void:
	force_action.emit(ChangeTileRotationAction.new(Attacker, Game.getRelativeTileRotation(Attacker.Tile, Defender.Tile)))
	force_action.emit(ChangeTileRotationAction.new(Defender, Game.getRelativeTileRotation(Defender.Tile, Attacker.Tile)))

func onPostAction() -> void:
	Attacker.onAttack()
	
	var actions: Array = [ChangeAttacksAction.new(Attacker, Attacker.attacks - 1)]
	if Attacker is CardGD:
		actions.append(StatAction.new(Attacker, Game.Stats.SPEED, 0, 0, true))
		
	actions.append(DamageAction.new(Attacker, Defender, Attacker.getAttackDamage()))
	onPushAction(actions)

func getDelay() -> float:
	return 1.25
