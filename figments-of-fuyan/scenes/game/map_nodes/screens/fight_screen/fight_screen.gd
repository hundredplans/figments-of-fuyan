extends MapNodeScreen

const FADE_IN_TIME: float = 1.5
@onready var BlackBackground: ColorRect = %BlackBackground
@onready var LevelLabel: Label = %LevelLabel
@onready var CurseIcon: TextureRect = %CurseIcon
@onready var DescriptionLabel: FancyTextLabel = %DescriptionLabel
@onready var CurseNameLabel: Label = %CurseNameLabel

func setInfo(_save_file: SaveFileGD, _area: AreaGD, _World: Node3D, _UI: Control, map_node: MapNodeGD) -> void:
	super(_save_file, _area, _World, _UI, map_node)
	LevelLabel.text = str(Game.area.getWorldDifficulty()) + "-" + str(map_node.map_location.progress) + ": " + map_node.level_info.name

	var is_elite: bool = map_node is EliteFightNodeGD
	if is_elite:
		CurseNameLabel.text = map_node.curse_info.name
		CurseIcon.texture = map_node.curse_info.icon
		DescriptionLabel.setText(map_node.curse_info.description)

	var alpha_tween := create_tween()
	alpha_tween.tween_property(BlackBackground, "color:a", 1, FADE_IN_TIME)
	await alpha_tween.finished
	finished.emit()
	#unque
	#await get_tree().process_frame
