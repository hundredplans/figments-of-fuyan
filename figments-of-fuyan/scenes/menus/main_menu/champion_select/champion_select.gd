extends Node3D

signal champion_pressed
#region Exports
@export var THETA_INCREMENT: int = 60
@export var PEDESTAL_RADIUS: float = 0.5
@export var UNIT_INFO_PATH: String
@export var starter_position: Vector3 = Vector3(1.25, 1.25, 2.9)
@export var PedestalPacked: PackedScene
#endregion

#region Base Functions
func _ready() -> void:
	position = starter_position
	var champions: Array = Helper.getResourcesRecursive(UnitInfoGD).filter(func(x: UnitInfoGD): return x.rarity == x.RARITIES.CHAMPION)
	@warning_ignore("narrowing_conversion")
	var theta: int = 180 - (champions.size() * THETA_INCREMENT * 0.25)
	for champion in champions:
		var pedestal: Node3D = PedestalPacked.instantiate()
		var _theta: float = deg_to_rad(theta)
		pedestal.position.x = PEDESTAL_RADIUS * cos(_theta)
		pedestal.position.z = PEDESTAL_RADIUS * sin(_theta)
		pedestal.rotation.y = atan2(-pedestal.position.x, -pedestal.position.z)
		add_child(pedestal)
		
		pedestal.setInfo(champion.getBaseData().onLoad(pedestal))
		
		pedestal.champion_hovered.connect(onChampionHovered)
		pedestal.champion_unhovered.connect(onChampionUnhovered)
		pedestal.champion_pressed.connect(onChampionPressed)
		theta += THETA_INCREMENT
#endregion

#region Hovered
var ChampionSpotlight: SpotLight3D
func onChampionHovered(Unit: UnitGD) -> void:
	ChampionSpotlight = SpotLight3D.new()
	ChampionSpotlight.light_color = Unit.info.associated_color
	ChampionSpotlight.position.y = Unit.getHeightInfo().stat_height
	Unit.add_child(ChampionSpotlight)
	
func onChampionUnhovered(_Unit: UnitGD) -> void:
	if ChampionSpotlight != null: ChampionSpotlight.queue_free()
	
func onChampionPressed(Unit: UnitGD) -> void:
	champion_pressed.emit(Unit)
#endregion
