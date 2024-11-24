extends Node3D

@onready var MerchantCrab: Node3D = %MerchantCrab
func setInfo(map_node: MapNodeGD) -> void:
	if !map_node.isFirstShop():
		rotation_degrees.y = 10
		position.x = -0.2

func onBuy() -> void:
	MerchantCrab.onBuy()
