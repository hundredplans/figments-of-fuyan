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
func onLoad(_save_file: SaveFileGD) -> void:
	save_file = _save_file
	save_file.update_shillings.connect(onUpdateShillings)
	onUpdateShillings(save_file.getShillings())
	area = save_file.area
	area.map_nodes_loaded.connect(onMapStartAnimation)
	area.map_node_entered.connect(onMapNodeEntered)
	area.map_node_finished.connect(onMapNodeFinished)
	area.map_node_hovered.connect(onMapNodeHovered)
	BackgroundDarkener.visible = false
#endregion

#region Area Name Label
func onMapStartAnimation() -> void:
	if !Helper.getAdmin():
		AreaNameLabel.text = area.info.name
		AniPlayer.play("MapStart")
#endregion

#region Shillings
func onUpdateShillings(count: int) -> void:
	ShillingsLabel.text = str(count)
#endregion

#region Map Node
var ActiveScreen: Control
func onMapNodeEntered(map_node: MapNodeGD) -> void:
	var screen_packed: PackedScene = map_node.info.screen
	if screen_packed != null:
		ActiveScreen = screen_packed.instantiate()
		BackgroundDarkener.visible = true
		ActiveScreen.finished.connect(area.onMapNodeFinished)
		add_child(ActiveScreen)
		ActiveScreen.setInfo(map_node, World, save_file)
	
func onMapNodeFinished(_map_node: MapNodeGD) -> void:
	BackgroundDarkener.visible = false
	if ActiveScreen != null: ActiveScreen.queue_free()

func onMapNodeHovered(map_node: MapNodeGD, state: bool) -> void:
	if state and map_node.get("HoverUI") != null:
		add_child(map_node.HoverUI)
		map_node.HoverUI.setInfo(map_node, area)
