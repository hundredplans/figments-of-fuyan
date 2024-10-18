extends Node

func _ready() -> void:
	var arr: Array = [5, 25, 399, 10, 30]
	var changed: bool = true
	while(changed):
		changed = false
		for i in range(1, arr.size()):
			if (arr[i] < arr[i - 1]):
				changed = true
				var old_value: int = arr[i]
				arr[i] = arr[i - 1]
				arr[i - 1] = old_value
