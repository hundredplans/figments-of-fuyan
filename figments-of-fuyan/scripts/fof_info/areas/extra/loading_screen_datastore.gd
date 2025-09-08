class_name LoadingScreenDatastore extends Resource

@export var name: String
@export var camera: PackedScene
@export var decoration: DecorationDatastore

func getDecorationDatastore() -> DecorationDatastore:
	return decoration
	
func getCamera() -> Camera3D:
	return camera.instantiate()

func getName() -> String:
	return name
