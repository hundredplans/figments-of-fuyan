extends Node2D

func _ready():
	var kids: Array = get_parent().get_node("CardZone").get_children()
	var teams: Array = kids.map(func(child: Control): return child.team)
	for i in range(kids.size()):
		match teams[i]:
			0: $Cards/TeamZero.text += kids[i].get_node("Name").text + "\n"
			1: $Cards/TeamOne.text += kids[i].get_node("Name").text + "\n"

func _on_x_pressed(): queue_free()


func _on_roll_zero_pressed(): on_roll_pressed(0)
func _on_roll_one_pressed(): on_roll_pressed(1)

func on_roll_pressed(team: int) -> void:
	var rollteam: TextEdit = $Cards/TeamZero
	if team == 1: rollteam = $Cards/TeamOne
	
	var rolled: Array = rollteam.text.split("\n", false)
	if rolled.size():
		match team:
			0: $Result/ResultZero.text = rolled[randi() % rolled.size()]
			1: $Result/ResultOne.text = rolled[randi() % rolled.size()]
