extends FancyTextLabel

var kill_amount: int
	
func setTier(kills: int, last_claimed_kills: int) -> void:
	if last_claimed_kills >= kill_amount:
		modulate = Color(1, 0, 0)
	elif kill_amount > kills:
		modulate = Color(0.6, 0.6, 0.6)
	else:
		modulate = Color(1, 1, 1)
		
func setKillAmount(_kill_amount: int) -> void:
	kill_amount = _kill_amount
