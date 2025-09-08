extends LevelGD

const GRASS_REPEATING_PATH: String = "res://scenes/game/levels/world/varoma/grass_repeating.tscn"

func onCreateLevelAreaDatastore() -> LevelAreaDatastore:
	return VaromaLevelAreaDatastore.new()

func onLoadActiveLevel(data: SavedDataLevel, _save_file: SaveFileGD) -> void:
	super(data, _save_file)
	onCreateVaromaDecorations()
	
func onCreateVaromaDecorations() -> void:
	pass
