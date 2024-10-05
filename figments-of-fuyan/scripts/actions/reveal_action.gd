class_name RevealAction extends Action

var GameObject: GameObjectGD

func _init(_GameObject: GameObjectGD = null) -> void:
	super()
	GameObject = _GameObject
	
func onPostAction() -> void:
	if GameObject is TileGD: for Obj in GameObject.occupied_objects: Obj.onRevealed()
	elif GameObject is ObjectGD: for Tile in GameObject.occupied_tiles: Tile.onRevealed()
	
	GameObject.onRevealed()
	onPushAction(LevelVisibleAction.new(true, [GameObject]))
	
