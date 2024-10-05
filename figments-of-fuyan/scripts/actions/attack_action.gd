class_name AttackAction extends Action

var Attacker: GameObjectGD
var Defender: GameObjectGD

func _init(_Attacker: GameObjectGD = null, _Defender: GameObjectGD = null) -> void:
	super()
	Attacker = _Attacker
	Defender = _Defender

func onPostAction() -> void:
	Attacker.setTileRotation(Game.getRelativeTileRotation(Attacker.Tile, Defender.Tile))
	Attacker.onAttack()
	
	onPushAction([ChangeAttacksAction.new(Attacker, Attacker.attacks - 1), StatAction.new(Attacker, Game.Stats.SPEED, 0, 0, 0, true), DamageAction.new(Attacker, Defender, Attacker.getAttackDamage())])

func getDelay() -> float:
	return 1.25
