extends Node3D

@onready var MerchantCrab: Node3D = %MerchantCrab
func setInfo(_map_node: MapNodeGD) -> void:
	pass

func onBuy() -> void:
	MerchantCrab.onBuy()
