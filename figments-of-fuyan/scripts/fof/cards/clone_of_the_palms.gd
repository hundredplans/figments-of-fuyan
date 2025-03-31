extends CardGD

func onProcessAction(action: Action) -> void:
	super(action)
	
func getDescription() -> String:
	return super()

func onCreateFieldInfo() -> void: pass
func onRemoveFieldInfo() -> void: pass
func onCanCreateInspectScreen() -> bool: return false
func onCanHoverOnTile() -> bool: return false
