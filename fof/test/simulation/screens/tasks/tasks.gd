extends Control

var can_drag: bool = false
var held: bool = true

func _ready() -> void:
	var text := FileAccess.open("res://test/simulation/screens/tasks/tasks.txt", FileAccess.READ).get_as_text().split("\n", false)
	var difficulties: Array = [0,0,0]
	for i in text: difficulties[int(i.split("-", false)[1]) - 1] += 1
	var roll_contents: Array = [convert_to_rarity(randf()), convert_to_rarity(randf())]
	roll_contents.append(roll_random(roll_contents))
	
	var y: int = 0
	for difficulty in roll_contents:
		var task: Control = preload("res://test/simulation/screens/tasks/single_task.tscn").instantiate()
		for i in text:
			if int(i.split("-", false)[1]) == difficulty:
				task.load_task(i)
				task.position.y += y
				$TaskNumbers.add_child(task)
				difficulties[difficulty - 1] -= 1
				break
		y += int(task.size.y)

func roll_random(roll_contents: Array) -> float:
	var i: int = convert_to_rarity(randf())
	if i not in roll_contents: return i
	return roll_random(roll_contents)

func convert_to_rarity(i: float) -> int:
	if i < 0.45: return 1
	elif i < 0.8: return 2
	elif i <= 1: return 3
	return 1

func _on_remove_button_pressed(): queue_free()

func _on_grab_zone_mouse_entered():
	can_drag = true

func _on_grab_zone_mouse_exited():
	can_drag = false

func _process(_delta: float) -> void:
	if can_drag or held:
		if Input.is_action_just_pressed("LeftClick"):
			held = true
		elif Input.is_action_pressed("LeftClick") and held:
			position.x = (get_viewport().get_mouse_position().x) - 390
			position.y = (get_viewport().get_mouse_position().y) - 160
		else:
			held = false
