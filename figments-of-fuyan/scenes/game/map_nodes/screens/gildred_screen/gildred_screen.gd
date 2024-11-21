extends Control

var save_file: SaveFileGD
@onready var MapEffectContainer: VBoxContainer = %MapEffectContainer
@export var gildred_blessing_label_packed: PackedScene
signal finished

func setInfo(_save_file: SaveFileGD, _area: AreaGD, World: Node3D, _UI: Control, map_node: MapNodeGD) -> void:
	save_file = _save_file
	for map_effect_datastore in map_node.selected_map_effects:
		var map_effect: MapEffectGD = SavedData.onLoadModel(map_effect_datastore.getSavedData(), World)
		map_effect.groupsave = false
		
		var GildredBlessingLabel: Control = gildred_blessing_label_packed.instantiate()
		MapEffectContainer.add_child(GildredBlessingLabel)
		GildredBlessingLabel.setInfo(map_effect)
		GildredBlessingLabel.pressed.connect(onMapEffectPressed.bind(map_effect))
		
func onMapEffectPressed(map_effect: MapEffectGD) -> void:
	map_effect.onPickup(save_file)
	finished.emit()
	queue_free()
	
func onDimBackground() -> bool:
	return true
