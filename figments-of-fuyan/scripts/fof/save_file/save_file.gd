class_name SaveFileGD extends FofGD

signal update_shillings

var id: int
var my_seed: int
var area: AreaGD
var shillings: int
var map_effects: Array
var time: int
var last_loaded_deck: Array

var timer: Timer

#region Save / Load
func onSaveToFile() -> void:
	#if !Helper.getAdmin():
		var saved_data: SavedDataSaveFile = onSave()
		saved_data.resource_path = SaveFileInfo.SAVE_DIRECTORY + str(id) + ".tres"
		ResourceSaver.save(saved_data)

func onSave() -> SavedData:
	return SavedDataSaveFile.new(id, my_seed, area.onSave(), shillings, SavedData.onSaveGroup(get_tree().get_nodes_in_group("MapEffectsGD")),\
	time + int(timer.wait_time - timer.time_left), SavedData.onSaveGroup(get_tree().get_nodes_in_group("DeckCardsGD")))

func onLoadData(data: SavedData) -> void:
	super(data)
	id = data.id
	my_seed = data.my_seed
	shillings = data.shillings
	map_effects = data.map_effects
	time = data.time
	last_loaded_deck = data.deck
	
	timer = Timer.new()
	timer.wait_time = 99999999999
	timer.set_autostart(true)
	
	add_to_group("SaveFilesGD")
#endregion

#region Base Functions
func _tree_exited() -> void:
	onSaveToFile()
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		onSaveToFile()
#endregion

#region Getters
func getShillings() -> int:
	return shillings
	
func onUpdateShillings(delta: int) -> void:
	shillings += delta
	update_shillings.emit(shillings)
#endregion
