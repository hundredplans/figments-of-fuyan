extends Node3D

@export var THETA_INCREMENT: int = 20
@export var PEDESTAL_RADIUS: float = 1
@export var UNIT_INFO_PATH: String
@export var starter_position: Vector3 = Vector3(1.25, 1.25, 2.9)
@export var PedestalPacked: PackedScene

func _ready() -> void:
	position = starter_position
	var champions: Array = Helper.getResourcesRecursive(UNIT_INFO_PATH, UnitInfoGD).filter(func(x: UnitInfoGD): return x.rarity == x.RARITIES.CHAMPION)
	@warning_ignore("integer_division")
	var theta: int = 0
	for champion in champions:
		var pedestal: Node3D = PedestalPacked.instantiate()
		var _theta: float = deg_to_rad(theta)
		pedestal.position.x = PEDESTAL_RADIUS * cos(_theta)
		pedestal.position.y = PEDESTAL_RADIUS * sin(_theta)
		add_child(pedestal)
		pedestal.setInfo(champion)
		pedestal.champion_hovered.connect(onChampionHovered)
		theta += THETA_INCREMENT
	
func onChampionHovered(Unit: UnitGD) -> void:
	pass
