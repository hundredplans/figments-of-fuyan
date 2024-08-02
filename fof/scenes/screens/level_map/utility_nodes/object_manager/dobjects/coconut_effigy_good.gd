extends DObjectGD

func onAfterDeath() -> void:
	Boons.onCreateBoonByID(6)
	super()
