class_name TeamRelationGD
extends Resource

var team: int
var relation: String

func _init(_team: int = 0, _relation: String = "Ally") -> void:
	team = _team
	relation = _relation
	
func onTeam() -> int:
	if team == 2: return -1
	if relation == "Ally": return team
	else: return abs(team - 1)
