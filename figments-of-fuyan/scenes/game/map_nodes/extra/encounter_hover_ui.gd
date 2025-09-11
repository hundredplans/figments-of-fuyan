extends HoverUI

@onready var EncounterMainUI: Control = %EncounterMainUI
@onready var NameLabel: Label = %NameLabel

func setInfo(map_node: MapNodeGD) -> void:
	var enc_datastore: EncounterDatastore = map_node.getEncounterDatastore()
	NameLabel.text = map_node.info.name
	NameLabel.modulate = enc_datastore.getBackgroundMainColor()
	setMouseCenter(get_viewport().get_mouse_position())

func setMouseCenter(mouse_position: Vector2) -> void:
	global_position = mouse_position - pivot_offset
