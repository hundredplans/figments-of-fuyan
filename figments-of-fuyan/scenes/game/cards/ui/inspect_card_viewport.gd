extends SubViewport

const ROTATION_SPEED: float = 1
const CAMERA_Y_OFFSET: float = 0
@onready var Camera: Camera3D = %Camera3D
@onready var ModelParent: Node3D = %ModelParent

var EmptyModel: Node3D
func setInfo(Card: CardGD) -> void:
	SavedData.onLoadModel(SavedDataTile.new(1, true), ModelParent).position.y -= 0.3
	EmptyModel = Card.onCreateEmptyModel(ModelParent)
	var ani_players: Array = Helper.getNodeTypeRecursive(EmptyModel, AnimationPlayer)
	if !ani_players.is_empty():
		ani_players[0].play("Idle")
	
	Camera.position.y = 3
	
	#Camera.look_at(Vector3(EmptyModel.global_position.x, Card.info.eye, EmptyModel.global_position.z))

func _process(delta: float) -> void:
	if EmptyModel != null: EmptyModel.rotation.y += ROTATION_SPEED * delta
