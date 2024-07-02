extends Control
var max_energy: int = 5

func setEnergy(energy: int) -> void:
	$Top.text = str(energy)
	$Top.modulate = Helper.BASE if energy != max_energy else Helper.YELLOW
	
func setMaxEnergy(energy: int) -> void:
	$Bottom.text = str(energy)
	max_energy = energy
