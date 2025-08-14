class_name VisionDatastoreCard extends VisionDatastore

var visibles: Dictionary # Dictionary of {GameObject: VisibleByUnit}
@export var visibles_public_ids: Dictionary
@export var vision_range: int = 5

#region Save / Load
func setInfo() -> void:
	for GameObject in (Game.get_tree().get_nodes_in_group("LevelTileObjectsGD") + Game.get_tree().get_nodes_in_group("FieldCardsGD"))\
	.filter(func(x: GameObjectGD): return !x.is_queued_for_deletion()):
		onAddVisibleGameObject(GameObject)
		
func onSave() -> void:
	visibles_public_ids = {}
	for GameObject in visibles.keys():
		visibles_public_ids[GameObject.public_id] = visibles[GameObject]
		visibles_public_ids[GameObject.public_id].onSave()
	
func onLoad() -> void:
	for game_object_public_id in visibles_public_ids.keys():
		var GameObject: GameObjectGD = Game.onFindPublicIDObject(game_object_public_id)
		visibles[GameObject] = visibles_public_ids[game_object_public_id]
		visibles[GameObject].onLoad()
#endregion

#region Getters
func getVisibleGameObjects() -> Array:
	return visibles.keys().filter(func(x: GameObjectGD): return visibles[x].isVisibleToUnit())
	
func getCardVisibles() -> Dictionary: # For debug can remove later
	var card_visibles: Dictionary = {}
	for Card in visibles.keys().filter(func(x: GameObjectGD): return x is CardGD):
		card_visibles[Card] = visibles[Card]
	return card_visibles
	
func getVisibles() -> Dictionary:
	return visibles
#endregion

#region Setters
func setDirect(GameObject: GameObjectGD, direct: bool) -> void:
	visibles[GameObject].setDirect(direct)
	
func onAddVisibleGameObject(GameObject: GameObjectGD) -> void:
	if visibles.has(GameObject): return
	if GameObject is TileGD: visibles[GameObject] = VisibleToUnitTile.new()
	elif GameObject is ObjectGD: visibles[GameObject] = VisibleToUnitObject.new()
	else: visibles[GameObject] = VisibleToUnitUnit.new()
	
func onRemoveVisibleGameObject(GameObject: GameObjectGD) -> void:
	if !visibles.has(GameObject): return
	
	visibles.erase(GameObject)
	if GameObject is TileGD:
		for Obj in GameObject.occupied_objects:
			visibles[Obj].by_tiles.erase(GameObject)
	
	elif GameObject is ObjectGD:
		for Tile in GameObject.occupied_tiles:
			visibles[Tile].by_objects.erase(GameObject)
	
#endregion

func getVisionRange() -> int:
	return vision_range

func onUpdateVisionRange(delta: int) -> void:
	vision_range = max(vision_range + delta, 1)
