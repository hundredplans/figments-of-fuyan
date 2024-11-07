extends IObjectGD

func isAttackable(_Card: CardGD) -> bool:
	return true

func getAttackableTile() -> TileGD:
	return occupied_tiles[0]

func onWasDamaged(action: DamageAction) -> void:
	onPushAction(IObjectDamagedAction.new(self, action))

func onIObjectDamaged(action: DamageAction) -> void:
	pass
