extends VFXGD

const PATH_TO_SPINNING_SWORD_VFX: String = "res://assets/models/vfx/units/spinning_sword_vfx.glb"

const RADIUS: float = 0.8
const SWORD_AMOUNT: int = 4
const SPEED: float = 20.0
var SwordManager: Node3D

func onVFX() -> void:
	super()
	SwordManager = Model.get_node("SwordManager")
	
	var theta: float = 0
	var theta_increment: float = (2 * PI) / float(SWORD_AMOUNT)
	for __: int in range(SWORD_AMOUNT):
		var Sword: Node3D = load(PATH_TO_SPINNING_SWORD_VFX).instantiate()
		var SwordNode := Node3D.new()
		SwordManager.add_child(SwordNode)
		SwordNode.add_child(Sword)
		Sword.position.z = RADIUS
		SwordNode.rotation.y = theta
		theta += theta_increment
	
func _process(delta: float) -> void:
	if SwordManager == null: return
	for SwordNode: Node3D in SwordManager.get_children():
		var SwordChild: Node3D = SwordNode.get_child(0)
		SwordChild.look_at(global_position)
		SwordChild.rotation = Vector3(0, SwordChild.rotation.y, 0)
	SwordManager.rotation_degrees.y += (delta * SPEED)
