extends MapNodeScreen

@onready var BlackBackground: ColorRect = %BlackBackground
@onready var LevelLabel: Label = %LevelLabel
@onready var CurseIcon: TextureRect = %CurseIcon
@onready var DescriptionLabel: FancyTextLabel = %DescriptionLabel
@onready var CurseNameLabel: Label = %CurseNameLabel

func setInfo(_save_file: SaveFileGD, _area: AreaGD, _World: Node3D, _UI: Control, _map_node: MapNodeGD) -> void:
	super(_save_file, _area, _World, _UI, _map_node)
	LevelLabel.text = str(Game.area.getWorldDifficulty()) + "-" + str(map_node.map_location.progress) + ": " + map_node.level_info.name

	var is_elite: bool = map_node is EliteFightNodeGD
	if is_elite:
		var curse_info: BoonInfo = Helper.getFofInfoID(BoonInfo, map_node.curse_id)
		CurseNameLabel.text = curse_info.name
		CurseIcon.texture = curse_info.icon
		DescriptionLabel.setText(curse_info.description)

	var alpha_tween := create_tween()
	alpha_tween.tween_property(BlackBackground, "color:a", 1, Game.FADE_TIME)
	await alpha_tween.finished
	finished.emit()
	#unque
	#await get_tree().process_frame
