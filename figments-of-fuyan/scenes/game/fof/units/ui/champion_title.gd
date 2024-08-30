extends Node3D

const CHAMPION_TITLE_OFFSET: float = 0.5
@onready var NameLabel: Label3D = %NameLabel
@onready var EpithetLabel: Label3D = %EpithetLabel
func setInfo(Card: CardGD) -> void:
	NameLabel.text = Card.info.name
	EpithetLabel.text = Card.info.epithet
	EpithetLabel.modulate = Card.info.associated_color
	
	await get_tree().process_frame
	EpithetLabel.position.x = NameLabel.get_aabb().size.x / 2
	position.y = Card.info.height.stat + CHAMPION_TITLE_OFFSET
	
