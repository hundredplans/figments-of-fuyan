class_name HandCardGD
extends Node

var id: int = 0
var energy: int = 0
var tool: ToolGD

func on_create_card(_id: int) -> void:
	id = _id
	energy = Helper.getCard(id).energy

func onEquipTool(_tool: ToolGD) -> void:
	tool = _tool
