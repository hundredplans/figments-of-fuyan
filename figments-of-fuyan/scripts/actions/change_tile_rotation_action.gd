class_name ChangeTileRotationAction extends Action

var GameObject: GameObjectGD
var tile_rotation: int

func _init(_GameObject: GameObjectGD = null, _tile_rotation: int = 0) -> void:
	GameObject = _GameObject
	tile_rotation = _tile_rotation
	
func onPostAction() -> void:
	GameObject.setTileRotation(tile_rotation)
