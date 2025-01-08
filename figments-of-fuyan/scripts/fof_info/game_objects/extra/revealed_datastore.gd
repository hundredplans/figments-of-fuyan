class_name RevealedDatastore extends Resource

var owner: FofGD
@export var revealed_id: int
@export var team: int # -1 for all teams, team for which the object is revealed for
@export var owner_public_id: int

# Create via Game.onCreateRevealedDatastore()
func setInfo(_owner: FofGD, _revealed_id: int, _team: int) -> void:
	owner = _owner
	revealed_id = _revealed_id
	team = _team
	
func onSave() -> void:
	owner_public_id = owner.public_id
	
func onLoad() -> void:
	owner = Game.onFindPublicIDObject(owner_public_id)
