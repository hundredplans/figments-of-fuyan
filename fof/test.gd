extends Node
	
func _ready() -> void:
	print(getStr())
	
func getStr() -> String:
	var test_data: Array = ["ab", "a"]
	var accumulate: String = ""
	var i: int = 0
	
	while (test_data.all(func(x: String): return x.length() > i and x.substr(0, i) == accumulate)):
		accumulate += test_data[0][i]
		i += 1
		if accumulate == test_data[0]: return accumulate
	return accumulate.left(-1)
	
#@onready var label := %Label
#func printNum(i: int) -> void:
	#label.text += str(i) + "\n"
#
#func isPalindrome(x: String) -> void:
	#var half_point: int = floor(x.length() / 2)
	#var half: String = x.substr(0, half_point)
	#var other_half: String = x.substr(half_point + (0 if x.length() % 2 == 0 else 1))
	#
	#if half == other_half.reverse(): printNum(int(x))
#
#
#func _on_line_edit_text_submitted(input: String):
	#isPalindrome(input)
