extends MapNodeGD

var selected_map_effects: Array[MapEffectDatastore] = []
const SELECTION_AMOUNT: int = 3
func onFofInit() -> void:
	var gildred_node_resources: Node3D = load(info.GILDRED_NODE_RESOURCES).instantiate()
	var resources: Array = gildred_node_resources.map_effects.duplicate()
	for i in range(SELECTION_AMOUNT):
		var index: int = randi() % resources.size()
		var map_effect_datastore: MapEffectDatastore = resources[index]
		map_effect_datastore.onCheckRandomise()
		selected_map_effects.append(map_effect_datastore)
		resources.remove_at(index)
		
func onSave() -> SavedDataMapNode:
	return SavedDataMapNodeGildred.new(info.id, false, public_id, map_location, links, is_entered, is_finished, rotation.y, selected_map_effects)

func onLoadData(data: SavedData) -> void:
	super(data)
	selected_map_effects = data.selected_map_effects
