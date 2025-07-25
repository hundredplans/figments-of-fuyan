extends Control

@onready var AreaBackground: TextureRect = %AreaBackground
@onready var Background: TextureRect = %Background
@onready var ArtPop: TextureRect = %ArtPop
@onready var NameLabel: Label = %NameLabel

@onready var AttackLineEdit: LineEdit = %AttackLineEdit
@onready var HealthLineEdit: LineEdit = %HealthLineEdit
@onready var SpeedLineEdit: LineEdit = %SpeedLineEdit
@onready var EnergyLineEdit: LineEdit = %EnergyLineEdit
@onready var CardTextEdit: TextEdit = %CardTextEdit

@export var rarities: Array[Image]
var tier: int
var card_info: CardInfo

func setInfo(_card_info: CardInfo, _tier: int) -> void:
	card_info = _card_info
	tier = _tier
	NameLabel.text = card_info.name
	AreaBackground.texture = ImageTexture.create_from_image(\
		getCardInfoArea(card_info).card_background)
	Background.texture = ImageTexture.create_from_image(\
		rarities[card_info.rarity])
	ArtPop.texture = card_info.getArtPop()

	var tier_datastore: CardTierDatastore = card_info.getTierDatastore(tier)
	AttackLineEdit.text = str(tier_datastore.attack) if tier_datastore.attack != -1 else ""
	HealthLineEdit.text = str(tier_datastore.health) if tier_datastore.health != -1 else ""
	SpeedLineEdit.text = str(tier_datastore.speed) if tier_datastore.speed != -1 else ""
	EnergyLineEdit.text = str(tier_datastore.energy) if tier_datastore.energy != -1 else ""
	CardTextEdit.text = tier_datastore.getDescription(false)
	
func onUpdateTierDatastore(tier_datastore: CardTierDatastore) -> void:
	var attack: int = int(AttackLineEdit.text) if AttackLineEdit.text != "" else -1
	var health: int = int(HealthLineEdit.text) if HealthLineEdit.text != "" else -1
	var speed: int = int(SpeedLineEdit.text) if SpeedLineEdit.text != "" else -1
	var energy: int = int(EnergyLineEdit.text) if EnergyLineEdit.text != "" else -1
	var description: String = CardTextEdit.text
	
	if tier_datastore.description_datastore == null:
		tier_datastore.description_datastore = DescriptionDatastore.new()
	tier_datastore.attack = attack
	tier_datastore.health = health
	tier_datastore.speed = speed
	tier_datastore.energy = energy
	tier_datastore.description_datastore.description = description
	
func getCardInfoArea(info: CardInfo) -> AreaInfo:
	for area_info in Helper.getFofInfoArray(AreaInfo):
		if info.id in area_info.card_ids: return area_info
	return null
	
func onSaveToCardInfo() -> void:
	var tier_datastore: CardTierDatastore = card_info.getTierDatastore(tier)
	onUpdateTierDatastore(tier_datastore)
	card_info.tiers[tier - 1] = tier_datastore
	ResourceSaver.save(card_info)
