extends Control

@onready var NameLabel: Label = %NameLabel
@onready var TxRect: TextureRect = %TextureRect

func setInfo(map_node: MapNodeGD) -> void:
	TxRect.texture = map_node.info.icon
	NameLabel.text = map_node.info.name
