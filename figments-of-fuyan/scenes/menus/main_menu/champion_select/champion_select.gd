extends Node3D

@export var RADIUS: float = 1.5
@export var BaseMaterial: Material

@export var DefaultLightPacked: PackedScene
@export var background_decoration_datastore: DecorationDatastore
@onready var AniPlayer: AnimationPlayer = %AniPlayer
@onready var ChampionCardsNode: Node3D = %ChampionCardsNode
@onready var Decoration: Node3D = %Decoration

var champion_cards: Array = []
func _ready() -> void:
	var champions: Array = Helper.getFofInfoArray(ChampionCardInfo)
	
	var theta: float = 0
	var theta_increment: float = (2 * PI) / champions.size()
	
	add_child(DefaultLightPacked.instantiate())
	
	for champion_info: ChampionCardInfo in champions:
		var card_data := Game.onCreateBaseCard(champion_info.id)
		var ChampionCard: CardGD = SavedData.onLoadModel(card_data, ChampionCardsNode)
		ChampionCard.onCreateModel()
		ChampionCard.onCreateFieldInfo()
		ChampionCard.setFieldInfoVisible(false)
		
		ChampionCard.FieldInfo.setInfoSpriteTexture(null)
		ChampionCard.FieldInfo.position.z = RADIUS
		
		ChampionCard.setMeshesMaterial(BaseMaterial, ChampionCard.getModel())
		ChampionCard.FieldInfo.setDepthTest(true)
		ChampionCard.FieldInfo.setWhiteNumbersDepthTest(true)
		
		ChampionCard.getModel().position.z = RADIUS
		ChampionCard.getModel().rotation.y = 0
		ChampionCard.rotation.y = theta
		ChampionCard.onIdle()
		champion_cards.append(ChampionCard)
		
		theta += theta_increment
		
	for data: SavedDataTileObject in background_decoration_datastore.data:
		SavedData.onLoadModel(data, Decoration)

func getChampionCards() -> Array:
	return champion_cards
	
func onRotateChampions(direction: int, time: float) -> void:
	var value: float = direction * ((2 * PI) / champion_cards.size())
	for ChampionCard: CardGD in ChampionCardsNode.get_children():
		var tween := create_tween()
		tween.tween_property(ChampionCard, "rotation:y", value, time)\
			.as_relative().set_trans(Tween.TRANS_SINE)
	
func onViewChampion(active_champion_index: int, time: float) -> void:
	var ChampionCard: CardGD = champion_cards[active_champion_index]
	ChampionCard.setFieldInfoVisible(true)
	var other_cards: Array = champion_cards.filter(func(x: CardGD): return x != ChampionCard)
	AniPlayer.play("ViewChampion")
	
	for OtherCard: CardGD in other_cards:
		OtherCard.onTweenAlphagreyValue(0.0, time)

func onUnviewChampion(active_champion_index: int, time: float) -> void:
	var ChampionCard: CardGD = champion_cards[active_champion_index]
	ChampionCard.setFieldInfoVisible(false)
	var other_cards: Array = champion_cards.filter(func(x: CardGD): return x != ChampionCard)
	AniPlayer.play_backwards("ViewChampion")
	
	for OtherCard: CardGD in other_cards:
		OtherCard.onTweenAlphagreyValue(1.0, time)
