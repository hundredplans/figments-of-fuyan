extends Control

@onready var TxRect: TextureRect = %TextureRect

func setInfo(tx: Texture2D) -> void: # null tx means it's a filler
	TxRect.texture = tx
