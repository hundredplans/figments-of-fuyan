extends MarginContainer

const SHIELD_ID: int = 3
const ARMOR_ID: int = 1

@onready var BossShieldUI: Control = %BossShieldUI
@onready var BossNameLabel: Label = %BossNameLabel
@onready var HealthBar: Control = %HealthBar

const FULL_HEALTHBAR_SIZE_X: int = 1070

func setInfo() -> void:
	var BossCard: EpicCardGD = Game.getLevel().getBoss()
	BossNameLabel.modulate = Game.getRarityColor(BossCard.info.rarity)
	onUpdateBossNameLabel(BossCard)
	setHealthBar(BossCard)
	setBossShieldUI(BossCard.getFirstFieldEffect(SHIELD_ID) != null)

func setHealthBar(BossCard: CardGD) -> void:
	HealthBar.size.x = FULL_HEALTHBAR_SIZE_X * (BossCard.health / float(BossCard.max_health))
	
	var health_bar_color := Color("ff0000")
	if BossCard.getFieldTraitByID(ARMOR_ID) != null:
		health_bar_color = Color("7d4545")
		
	HealthBar.modulate = health_bar_color
	
func onUpdateBossNameLabel(BossCard: CardGD) -> void:
	BossNameLabel.text = BossCard.getNameFromInfo()

func setBossShieldUI(vis: bool) -> void:
	BossShieldUI.visible = vis
