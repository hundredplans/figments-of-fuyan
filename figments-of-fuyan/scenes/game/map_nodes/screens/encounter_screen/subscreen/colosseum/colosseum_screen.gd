extends EncounterSubscreen

@export var foreign_fight_icon: Texture2D
@export var curse_fight_icon: Texture2D
@export var advanced_fight_icon: Texture2D
@export var mirror_fight_icon: Texture2D

@export_multiline var foreign_fight_description: String
@export_multiline var curse_fight_description: String
@export_multiline var advanced_fight_description: String
@export_multiline var mirror_fight_description: String

@export var background_transparency: float = 0.5
@onready var EncounterMainUI: Control = %EncounterMainUI

@onready var LeftRect: Control = %LeftRect
@onready var RightRect: Control = %RightRect

@onready var LeftTitleLabel: Label = %LeftTitleLabel
@onready var RightTitleLabel: Label = %RightTitleLabel

@onready var LeftIcon: TextureRect = %LeftIcon
@onready var RightIcon: TextureRect = %RightIcon

@onready var LeftDescriptionLabel: Label = %LeftDescriptionLabel
@onready var RightDescriptionLabel: Label = %RightDescriptionLabel

var is_mouse_in_left_rect: bool
var is_mouse_in_right_rect: bool
var disabled: bool

func setInfo(_map_node: MapNodeGD) -> void:
	super(_map_node)
	
	get_viewport().update_mouse_cursor_state()
	var base_sprite: Texture2D = map_node.getEncounterDatastore().getBaseSprite()
	var frames: Array[Texture2D] = map_node.getEncounterDatastore().getFrames()
	EncounterMainUI.setInfo(base_sprite, frames)
	
	var TITLE_LABELS: Array = [LeftTitleLabel, RightTitleLabel]
	var ICON_RECTS: Array = [LeftIcon, RightIcon]
	var DESCRIPTION_LABELS: Array = [LeftDescriptionLabel, RightDescriptionLabel]

	var chosen_fight_types: Array = map_node.getChosenSpecialFights()
	for i: int in range(2):
		var TitleLabel: Label = TITLE_LABELS[i]
		var IconRect: TextureRect = ICON_RECTS[i]
		var DescriptionLabel: Label = DESCRIPTION_LABELS[i]
		var chosen_fight_type: String = chosen_fight_types[i]
		
		IconRect.texture = getColosseumIcon(chosen_fight_types[i])
		DescriptionLabel.text = getColosseumDescription(chosen_fight_types[i])
		TitleLabel.text = chosen_fight_types[i]
	
func onLeftRectHovered() -> void:
	if disabled: return
	LeftRect.color.a = background_transparency
	RightRect.color.a = 0
	
func onRightRectHovered() -> void:
	if disabled: return
	LeftRect.color.a = 0
	RightRect.color.a = background_transparency

func getColosseumIcon(type: String) -> Texture2D:
	match type:
		"Foreign Fight": return foreign_fight_icon
		"Mirror Fight": return mirror_fight_icon
		"Curse Fight": return curse_fight_icon
		"Advanced Fight": return advanced_fight_icon
	return null
	
func getColosseumDescription(type: String) -> String:
	match type:
		"Foreign Fight": return foreign_fight_description
		"Mirror Fight": return mirror_fight_description
		"Curse Fight": return curse_fight_description
		"Advanced Fight": return advanced_fight_description
	return ""

func onMouseInLeftRect(state: bool) -> void:
	is_mouse_in_left_rect = state
	
func onMouseInRightRect(state: bool) -> void:
	is_mouse_in_right_rect = state

func onRectChosen(is_right: bool) -> void:
	disabled = true
	map_node.onCreateSpecialFight(is_right)
	onFadeBackgroundBlack()
	
	for rect: Control in [LeftRect, RightRect]:
		var ntween := create_tween()
		ntween.tween_property(self, "color:a", 1.0, Game.FADE_TIME)

func getMinimapFadeNodes() -> Array: return [EncounterMainUI, LeftRect, RightRect]
func getStashFadeNodes() -> Array: return [EncounterMainUI, LeftRect, RightRect]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("MainInput") and !disabled:
		if is_mouse_in_left_rect: onRectChosen(false)
		elif is_mouse_in_right_rect: onRectChosen(true)
