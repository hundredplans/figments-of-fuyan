extends CardGD

var is_clone_summon: bool
func onProcessAction(action: Action) -> void:
	super(action)
	
func getDescription() -> String:
	return super()

func onCreateFieldInfo() -> void: pass
func onRemoveFieldInfo() -> void: pass
func onCanCreateInspectScreen() -> bool: return false
