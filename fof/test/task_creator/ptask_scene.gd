extends Control
@export var CategoryInput: Label
@export var TypeInput: Label
@export var DescriptionInput: Label
@export var EDTInput: Label
@export var NecessityInput: Label 
var ptask: PTaskGD
signal delete

func setInfo(_ptask: PTaskGD) -> void:
	ptask = _ptask
	CategoryInput.text = PTaskGD.Category.keys()[PTaskGD.Category.values()[ptask.category]]
	TypeInput.text = PTaskGD.Type.keys()[PTaskGD.Type.values()[ptask.type]]
	DescriptionInput.text = ptask.description
	EDTInput.text = str(ptask.EDT)
	NecessityInput.text = str(ptask.necessity)

func _on_delete_button_pressed():
	delete.emit()

func _on_set_button_pressed():
	ResourceSaver.save(ptask, "user://save/ptasks/0.tres")
