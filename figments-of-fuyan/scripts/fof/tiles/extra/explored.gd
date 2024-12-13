class_name ExploredGD extends Resource

@export var teams: Array[int]
func getExploredByTeam(team: int) -> bool:
	return team in teams
	
func addExploredTeam(team: int) -> void:
	teams.append(team)
