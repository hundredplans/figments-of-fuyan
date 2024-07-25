extends Control

@export var start_position: int = 950
@export var end_position: int = 150
@export var travel_time: float = 2.0
@export var delay_between_spawn: float = 0.1
@export var label_packed: PackedScene

var to_process: Array = []

func onSpawn(temp_text_info: TempTextInfoGD) -> void:
	to_process.append("[center]" + temp_text_info.getText() + "[/center]")

func _on_timer_timeout():
	if !to_process.is_empty():
		var label: RichTextLabel = label_packed.instantiate()
		add_child(label)
		label.text = to_process.pop_front()
		label.position.y = start_position
		
		var tween := create_tween()
		tween.tween_property(label, "position:y", end_position, travel_time)
		tween.finished.connect(label.queue_free)
		
		var vis_tween := create_tween()
		vis_tween.tween_property(label, "modulate:a", 0.0, travel_time - 0.05)

