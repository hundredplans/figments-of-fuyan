class_name SaveFile extends Resource


@export var save_slot: int
@export var my_seed: int
@export var overworld_level_data: SavedDataOverworldLevel

func _init() -> void:
	save_slot = getSaveSlotCount() + 1
	overworld_level_data = Helper.getResourcesRecursive(OverworldLevelInfoGD)[0].getBaseData()
	overworld_level_data.map_location = MapLocation.new(0, 0, 1, 1)
	my_seed = randi()
	Random.setSeed(my_seed)
	ResourceSaver.save(self, INFO_PATH + str(save_slot) + ".tres")

#region Save Slots
static var INFO_PATH: String = "user://save/save_files/"
static func getSaveSlotCount() -> int:
	return Helper.getResourcesRecursive(SaveFile).size()
#endregion
