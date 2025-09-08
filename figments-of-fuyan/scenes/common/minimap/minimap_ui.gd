extends Control

signal exit

var is_exiting: bool
@onready var FadeBackground: Control = %FadeBackground

func onMapNodeHovered(map_node: MapNodeGD, state: bool, HoverUI: Variant = null) -> void:
	if HoverUI != null: Game.onEmptyTooltip(state, HoverUI, self)
	if state and HoverUI != null:
		HoverUI.setInfo(map_node)

func setInfo() -> void:
	for map_node: MapNodeGD in get_tree().get_nodes_in_group("MapNodesGD"):
		map_node.hovered.connect(onMapNodeHovered)
		map_node.is_minimap = true
	
	FadeBackground.modulate.a = 1.0
	FadeBackground.onFade(true)

func onExit() -> void:
	if is_exiting: return
	is_exiting = true
	
	exit.emit()
	
	Game.getArea().onClearMapNodes()
	queue_free()
	
