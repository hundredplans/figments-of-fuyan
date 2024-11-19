extends Node

func _ready() -> void:
	var x: String = "ABRAKADABRA"
	var y: String = "BARNABA"
	
	var s: Array = []
	var s_fill: Array = []
	s_fill.resize(y.length())
	s_fill.fill(0)
	
	s.resize(x.length())
	s.fill(s_fill)
	print(s)
	print()
	 
	for i in range(1, x.length()):
		for j in range(1, y.length()):
			if x[i - 1] != y[j - 1]:
				s[i][j] = max(s[i][j - 1], s[i - 1][j])
			else:
				s[i][j] = s[i - 1][j - 1] + 1
	
	print(s)
	for i in range(s.size()):
		for j in range(s[i].size()):
			var label := Label.new()
			label.text = str(s[i][j])
			label.position = Vector2(50 * j, 50 * i)
			add_child(label)
	
