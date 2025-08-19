extends HoverUI

@onready var EncounterMainUI: Control = %EncounterMainUI
@onready var NameLabel: Label = %NameLabel

func setInfo(map_node: MapNodeGD) -> void:
	var enc_datastore: EncounterDatastore = map_node.getEncounterDatastore()
	NameLabel.text = map_node.info.name
	NameLabel.modulate = enc_datastore.getBackgroundMainColor()
	
	var base_sprite: Texture2D = enc_datastore.getBaseSprite()
	var frames: Array[Texture2D] = enc_datastore.getFrames()
	
	EncounterMainUI.setInfo(base_sprite, frames)
	setMouseCenter(get_viewport().get_mouse_position())
