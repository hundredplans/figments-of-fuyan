class_name SaveFileGD extends FofGD

signal update_shillings

var id: int
var my_seed: int
var area: AreaGD
var shillings: int
var map_effects: Array

#region Save / Load
func onSave() -> SavedData:
	return SavedDataSaveFile.new(id, my_seed, area.onSave(), shillings, SavedData.onSaveGroup(get_tree().get_nodes_in_group("MapEffectsGD")))

func onLoadData(data: SavedData) -> void:
	super(data)
	id = data.id
	my_seed = data.my_seed
	shillings = data.shillings
	map_effects = data.map_effects
	add_to_group("SaveFilesGD")
#endregion

#region Getters
func getShillings() -> int:
	return shillings
	
func onUpdateShillings(delta: int) -> void:
	shillings += delta
	update_shillings.emit(shillings)
#endregion
