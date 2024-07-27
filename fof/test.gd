extends Node
	
@onready var label := %Label
func printNum(i: int) -> void:
	label.text += str(i) + "\n"

func isPalindrome(x: String) -> void:
	var half_point: int = floor(x.length() / 2)
	var half: String = x.substr(0, half_point)
	var other_half: String = x.substr(half_point + (0 if x.length() % 2 == 0 else 1))
	
	if half == other_half.reverse(): printNum(int(x))


func _on_line_edit_text_submitted(input: String):
	isPalindrome(input)
