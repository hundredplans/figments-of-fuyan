extends IObjectGD

func onLoadDataLevel() -> void:
	super()
	Model.visible = false
	setCollisionLayers(0)
	
func onLoadDataLevelFofInit() -> void:
	super()
	var revealed_datastore := Game.onCreateRevealedDatastore(self, 0)
	onPushAction(RevealAction.new(self, revealed_datastore))
