class_name UnitGD
extends GameObjectGD

#region Saved Data
var team: int
#endregion

#region Globals
var Model: Node3D
#endregion

#region Signals
signal mouse_entered
signal mouse_exited
#endregion

#region Setters
func setOwner(node: Node) -> void:
	owner = node
	get_child(0).owner = node

func setScale(_scale: Vector3) -> void:
	scale = _scale
	
func setScaleUniform(x: float) -> void:
	scale = Vector3(x, x, x)

func setDefaultCollisionLayers() -> void:
	for body in getStaticBodies(): body.collision_layer = 480
	
func setMapPosition() -> void:
	position = Vector3((sqrt(3) * coords.x + sqrt(3) * coords.y * 0.5), (coords.w * 0.6) + 0.3, coords.y * 3 / 2.0)
#endregion

#region Getters
func getHeightInfo() -> UnitHeightInfoGD:
	return info.getHeight(variation)
	
func getArtPop() -> Image:
	return info.getArtPop(variation)
#endregion

#region Animation

func setAniPlayer() -> void:
	for child in Helper.getChildrenRecursive(self):
		if child is AnimationPlayer: AniPlayer = child; return

var AniPlayer: AnimationPlayer
func onIdle() -> void:
	if AniPlayer != null: AniPlayer.play("Idle")
#endregion

#region Card
func onCreateCardUI(parent: Control) -> Control:
	var CardUI: Control = load(info.CARD_UI_SCENE_PATH).instantiate()
	parent.add_child(CardUI)
	CardUI.setInfo(self)
	return CardUI
#endregion

#region Save/Load/Clear
func onSave() -> SavedDataGameObject:
	return SavedDataUnit.new(info.id, variation, coords, tile_rotation, team)

func onLoad(data: SavedData, parent: Node3D) -> void:
	super(data, parent)
	team = data.team
	if info.collision_shape != null:
		Model = get_child(0)
		var body := StaticBody3D.new()
		Model.add_child(body)
		body.add_child(info.collision_shape.instantiate())
		
		body.collision_mask = 0
		body.mouse_entered.connect(func(): mouse_entered.emit(self))
		body.mouse_exited.connect(func(): mouse_exited.emit(self))
		
	setDefaultCollisionLayers()
	setAniPlayer()
#endregion
