class_name SavedDataMapNodeStart extends SavedDataMapNode

func onLoadModel(parent: Node3D) -> MapNode:
	var model: MapNode = super(parent)
	model.onLoad(self, parent)
	return model
