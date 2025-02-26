extends MarginContainer

@onready var BossNameLabel: Label = %BossNameLabel
@onready var HealthBar: Control = %HealthBar

const FULL_HEALTHBAR_SIZE_X: int = 1070

func setInfo() -> void:
	var BossCard: BossCardGD = Game.getLevel().getBoss()
	BossNameLabel.text = BossCard.getNameFromInfo()
	setHealthBar(BossCard)

func setHealthBar(BossCard: CardGD) -> void:
	HealthBar.size.x = FULL_HEALTHBAR_SIZE_X * (BossCard.health / float(BossCard.max_health))
	
