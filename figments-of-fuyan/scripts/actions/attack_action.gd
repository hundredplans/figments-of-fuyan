class_name AttackAction extends Action

var Attacker: GameObjectGD
var Defenders: Array

func _init(_Attacker: GameObjectGD = null, _Defenders: Variant = null) -> void:
	super()
	Attacker = _Attacker
	
	if _Defenders is Array: Defenders = _Defenders
	elif _Defenders is GameObjectGD: Defenders = [_Defenders]
	
func onPreAction() -> void:
	setActionDelay(Game.ATTACK_DELAY if Attacker.isLevelVisible() or Defenders.any(func(x: GameObjectGD): return x.isLevelVisible()) else 0.0)
	onForceAction(ChangeAttacksAction.new(Attacker, Attacker.attacks - 1))
	
func onPostAction() -> void:
	var DefenderTile: TileGD = Defenders[0].getAttackableTile()
	
	var relative_tile_rotation: int = Game.getRelativeTileRotation(Attacker.Tile, DefenderTile)
	onForceAction(ChangeTileRotationAction.new(Attacker, relative_tile_rotation))
	for Defender in Defenders.filter(func(x: GameObjectGD): return x is CardGD):
		onForceAction(ChangeTileRotationAction.new(Defender, Game.getRelativeTileRotation(Defender.Tile, Attacker.Tile)))
	Attacker.onAttack(DefenderTile, action_delay)
	
	var actions: Array = []
	if Attacker is CardGD:
		actions.append(StatAction.new(StatInfo.new(Attacker, Game.Stats.SPEED, 0, 0, true, false, true)))
		
	actions.append(DamageAction.new(Attacker, Defenders, Attacker.getAttackDamage()))
	actions.append(ChangeTileRotationAction.new(Attacker, relative_tile_rotation)) # Change back for ranged
	onPushAction(actions)
