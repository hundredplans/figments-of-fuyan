extends Control
var out_of_total: int = 0
var out_of_current: int = 0

func load_task(_task: String) -> void:
	var task: Array = _task.split("-", false)
	out_of_total = int(task[3])
	$OutOf.text = "0/" + task[3].right(-1)
	$TaskName.text = task[0].left(-1)
	$TaskText.text = task[2].left(-1).right(-1)
	match int(task[1]):
		1: $Background.color = Color("63bd5c")
		2: $Background.color = Color("df8f55")
		3: $Background.color = Color("c61b23")

func _on_subtract_total_pressed():
	out_of_current = clamp(out_of_current - 1, 0, out_of_total)
	$OutOf.text = str(out_of_current) + "/" + str(out_of_total)

func _on_add_total_pressed():
	out_of_current = clamp(out_of_current + 1, 0, out_of_total)
	$OutOf.text = str(out_of_current) + "/" + str(out_of_total)
