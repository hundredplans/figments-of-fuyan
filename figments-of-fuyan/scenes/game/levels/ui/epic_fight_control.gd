extends MarginContainer

@onready var BossNameLabel: Label = %BossNameLabel
@onready var HealthBar: Control = %HealthBar

const FULL_HEALTHBAR_SIZE_X: int = 1070

func setInfo() -> void:
	var BossCard: EpicCardGD = Game.getLevel().getBoss()
	onUpdateBossNameLabel(BossCard)
	setHealthBar(BossCard)

func setHealthBar(BossCard: CardGD) -> void:
	HealthBar.size.x = FULL_HEALTHBAR_SIZE_X * (BossCard.health / float(BossCard.max_health))
	
	var health_bar_color := Color("ff0000")
	if BossCard.getFieldTraitByID(1) != null:
		health_bar_color = Color("7d4545")
		
	HealthBar.modulate = health_bar_color
	
func onUpdateBossNameLabel(BossCard: CardGD) -> void:
	BossNameLabel.text = BossCard.getNameFromInfo()
