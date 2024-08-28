extends Node3D

@onready var NameLabel: Label3D = %NameLabel
@onready var EpithetLabel: Label3D = %EpithetLabel
func setInfo(Unit: UnitGD) -> void:
	NameLabel.text = Unit.info.name
	EpithetLabel.text = Unit.info.epithet
	EpithetLabel.modulate = Unit.info.associated_color
	
	await get_tree().process_frame
	EpithetLabel.position.x = NameLabel.get_aabb().size.x / 2
	position.y = Unit.getHeightInfo().stat_height
	
