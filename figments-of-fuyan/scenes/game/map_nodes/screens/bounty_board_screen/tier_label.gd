extends FancyTextLabel

var original_text: String
var kill_amount: int

func setText(_text: String) -> void:
	super(_text)
	original_text = text
	
func setStrikethrough(kills: int, last_claimed_kills: int) -> void:
	modulate = Color(1, 1, 1)
	if kill_amount >= last_claimed_kills:
		modulate = Color(0.6, 0.6, 0.6)
	elif kills < kill_amount:
		text = "[s]" + original_text + "[/s]"
	else: text = original_text

func setKillAmount(_kill_amount: int) -> void:
	kill_amount = _kill_amount
