extends Node

@onready var IDContainer: Container = %IDContainer
@onready var MainContainer: Container = %MainContainer

const MIN_SIZE_X: int = 200

func _ready() -> void:
	for i in range(1, 200):
		var label := Label.new()
		label.text = str(i)
		label.custom_minimum_size.x = MIN_SIZE_X
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		IDContainer.add_child(label)

	for type: GDScript in Helper.GDSCRIPT_TYPES:
		var type_container := HBoxContainer.new()
		type_container.custom_minimum_size.y = 150
		MainContainer.add_child(type_container)
		
		var first_label := Label.new()
		first_label.text = type.getFofName()
		first_label.custom_minimum_size.x = 140
		first_label.modulate = Color(0.5, 0.5, 0.5)
		type_container.add_child(first_label)
		
		var arr: Array = Helper.getFofInfoArray(type)
		for key: FofInfo in arr:
			var label := Label.new()
			label.text = key.name
			label.custom_minimum_size.x = MIN_SIZE_X
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			type_container.add_child(label)
			
			
