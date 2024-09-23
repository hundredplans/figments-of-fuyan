extends Control

#region Globals
var World: Node3D
var save_file: SaveFileGD
var area: AreaGD
@onready var AreaNameLabel: Label = %AreaNameLabel
@onready var AniPlayer: AnimationPlayer = %UIAnimationPlayer
@onready var ShillingsLabel: Label = %ShillingsLabel
@onready var BackgroundDarkener: Control = %BackgroundDarkener
#endregion

#region Base Functions
func setInfo(_save_file: SaveFileGD) -> void:
	save_file = _save_file
	save_file.update_shillings.connect(onUpdateShillings)
	onUpdateShillings(save_file.getShillings())
	area = save_file.area
	area.map_node_finished.connect(onMapNodeFinished)
	area.map_node_hovered.connect(onMapNodeHovered)
	area.map_node_entered.connect(onMapNodeEntered)
	
	BackgroundDarkener.visible = false
	onMapStartAnimation()
#endregion

#region Area Name Label
func onMapStartAnimation() -> void:
	if !Helper.getAdmin() and !area.getEnteredMapNode().info.id > 1:
		AreaNameLabel.text = area.info.name
		AniPlayer.play("MapStart")
#endregion

#region Shillings
func onUpdateShillings(count: int) -> void:
	ShillingsLabel.text = str(count)
#endregion

#region Map Node
	
func onMapNodeEntered(map_node: MapNodeGD) -> void:
	if map_node.ActiveScreen != null:
		BackgroundDarkener.visible = true
		add_child(map_node.ActiveScreen)
		map_node.ActiveScreen.setInfo(map_node, World, save_file)
	
func onMapNodeFinished(_map_node: MapNodeGD) -> void:
	BackgroundDarkener.visible = false

func onMapNodeHovered(map_node: MapNodeGD, state: bool) -> void:
	if state and map_node.HoverUI != null:
		add_child(map_node.HoverUI)
		map_node.HoverUI.setInfo(map_node, area)
#endregion
