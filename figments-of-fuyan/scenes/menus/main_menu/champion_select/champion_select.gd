extends Node3D

signal champion_pressed
signal disable_freelook

#region Exports
@export var THETA_INCREMENT: int = 18
@export var PEDESTAL_RADIUS: float = 0.7
@export var UNIT_INFO_PATH: String
@export var starter_position: Vector3 = Vector3(1.25, 1.25, 2.9)
@export var PedestalPacked: PackedScene
@export var ChampionTitlePacked: PackedScene
var is_champion_pressed: bool
var ChampionCard: CardGD
#endregion

#region Base Functions
func _ready() -> void:
	position = starter_position
	var champions: Array = Helper.getFofInfoArray(ChampionCardInfo)
	@warning_ignore("narrowing_conversion")
	var theta: int = 162
	for i in range(20):
		var champion: CardInfo = champions[i] if i < champions.size() else null
		var pedestal: Node3D = PedestalPacked.instantiate()
		var _theta: float = deg_to_rad(theta)
		pedestal.position.x = PEDESTAL_RADIUS * cos(_theta)
		pedestal.position.z = PEDESTAL_RADIUS * sin(_theta)
		pedestal.rotation.y = atan2(-pedestal.position.x, -pedestal.position.z)
		add_child(pedestal)
		
		if champion != null:
			var card_data := Game.onCreateBaseCard(champion.id)
			ChampionCard = SavedData.onLoadModel(card_data, pedestal)
			ChampionCard.onCreateModel()
			ChampionCard.getModel().rotation.y = 0
			pedestal.setInfo(ChampionCard)
			
			pedestal.champion_hovered.connect(onChampionHovered)
			pedestal.champion_unhovered.connect(onChampionUnhovered)
			pedestal.champion_pressed.connect(onChampionPressed)
		theta += THETA_INCREMENT
		
func setInfo(travel: Signal) -> void:
	travel.connect(onTravel)
	
func onTravel(travel_info: CameraTravelDatastore) -> void:
	if travel_info.is_history and !travel_info.is_start and travel_info.end.name == "NewGame":
		is_champion_pressed = false
		onChampionUnhovered()
		disable_freelook.emit(false)
		
#endregion

#region Hovered
var ChampionTitle: Node3D
var ChampionSpotlight: SpotLight3D
func onChampionHovered(Card: CardGD) -> void:
	if is_champion_pressed: return
	onChampionUnhovered()
	
	ChampionSpotlight = SpotLight3D.new()
	ChampionSpotlight.light_color = Card.info.associated_color
	ChampionSpotlight.light_energy = 2
	ChampionSpotlight.position.y = Card.info.stat
	
	ChampionTitle = ChampionTitlePacked.instantiate()
	Card.add_child(ChampionTitle)
	ChampionTitle.setInfo(Card)
	
	Card.add_child(ChampionSpotlight)
	
func onChampionUnhovered(_Card: CardGD = null) -> void:
	if is_champion_pressed: return
	if ChampionSpotlight != null:
		ChampionSpotlight.queue_free()
		
	if ChampionTitle != null:
		ChampionTitle.queue_free()
	
func onChampionPressed(Card: CardGD) -> void:
	is_champion_pressed = true
	champion_pressed.emit(Card)
	disable_freelook.emit(true)
#endregion
