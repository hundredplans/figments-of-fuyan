extends DObjectGD

var palm_mini_tool_info: Resource = preload("res://assets/base_game/unique_tiles/extras/palm_mini_tool_info.tres")
var ObjModel: Node3D
const DROP_ODDS: Dictionary = {
	"COCONUT": 0.23,
	"MINI-TOOL": 0.05,
	"PALMY": 0.02,
}

func onReady() -> void:
	ObjModel = BaseTile.types[1].model

func onAttacked(DMGInfo: DMGInfoGD) -> void:
	# play hurt animation here
	var adjacent_tiles: Array = Tiles.getAdjacentTiles(BaseTile, 1, true)
	var top_tiles: Array = Tiles.getTopTiles(adjacent_tiles)
	var Attacker: UnitGD = DMGInfo.getAttacker()
	var AttackerTile: TileGD = Attacker.Tile if Attacker != null else null
	
	for Tile in top_tiles.filter(func(x: TileGD): return x.isTileFree() or x == AttackerTile):
		var random_key_gen := RandomKeyGenGD.new(["COCONUT", "MINI-TOOL", "PALMY"], [0.23, 0.05, 0.02])
		var roll: String = random_key_gen.onRoll()
		
		match roll:
			"COCONUT": pass
			"MINI-TOOL":
				var index: int = randi_range(0, palm_mini_tool_info.mini_tool_info.size() - 1)
				var mini_tool_id: int = palm_mini_tool_info.mini_tool_info[index].id
				if Tile == AttackerTile:
					Tools.onEquipTool(Attacker, palm_mini_tool_info.mini_tool_info[index].id)
				else: ObjectManager.onCreateIObject(Tile, palm_mini_tool_info.getIObjectID(mini_tool_id))
			"PALMY": pass
