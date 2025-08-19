class_name EncounterScreen extends MapNodeScreen

@export var ROWS: int = 5
@export var COLUMNS: int = 8
@export var H_SEPERATION: int = 200
@export var V_SEPERATION: int = 100

@onready var BackgroundIconContainer: Container = %BackgroundIconContainer
@onready var AniPlayer: AnimationPlayer = %AniPlayer
@onready var MapPanel: Control = %MapPanel
@onready var ExitButton: Control = %ExitButton

var Subscreen: EncounterSubscreen
var is_minimap_visible: bool

func setInfo(_save_file: SaveFileGD, _area: AreaGD, _World: Node3D, _UI: Control, _map_node: MapNodeGD) -> void:
	super(_save_file, _area, _World, _UI, _map_node)
	Game.update_stash_screen.connect(onUpdateStashScreen)
	onCreateBackgroundIcons()
	
	Subscreen = map_node.info.screen.instantiate()
	add_child(Subscreen)
	Subscreen.setInfo(map_node)
	Subscreen.create_stash_screen.connect(func(x: TbcUI): create_stash_screen.emit(x))
	
func _on_exit_button_pressed() -> void:
	finished.emit()
	Subscreen.onFinished()

func onFadeBackground() -> bool:
	return true

func onCreateBackgroundIcons() -> void:
	AniPlayer.play("LoopBackgroundIcons")
	BackgroundIconContainer.columns = COLUMNS
	BackgroundIconContainer.add_theme_constant_override("h_separation", H_SEPERATION)
	BackgroundIconContainer.add_theme_constant_override("v_separation", V_SEPERATION)
	var icon: Texture2D = map_node.getEncounterDatastore().getBackgroundIcon()
	for __: int in range(COLUMNS * ROWS):
		var TxRect := TextureRect.new()
		TxRect.texture = icon
		BackgroundIconContainer.add_child(TxRect)
		
func onUpdateStashScreen(created: bool) -> void:
	var end_value: float = 0.0 if created else 1.0
	for node: Control in [ExitButton, MapPanel] + Subscreen.getStashFadeNodes():
		var tween := create_tween()
		tween.tween_property(node, "modulate:a", end_value, Game.FADE_TIME)

func onMinimapButtonPressed() -> void:
	is_minimap_visible = !is_minimap_visible
	var nodes: Array = [BackgroundIconContainer] + Subscreen.getMinimapFadeNodes()
	if !is_minimap_visible:
		for node: Control in nodes:
			node.visible = true

	var desired: float = int(!is_minimap_visible)
	var val: float = desired - BackgroundIconContainer.modulate.a
	for node: Control in nodes:
		var tween := create_tween()
		tween.tween_property(node, "modulate:a", val, Game.FADE_TIME).as_relative()
	minimap_mode.emit(is_minimap_visible)
	
	await get_tree().create_timer(Game.FADE_TIME).timeout
	if is_minimap_visible:
		for node: Control in nodes:
			node.visible = false

func getFadeBackgroundColor() -> Color: return Subscreen.getFadeBackgroundColor()
func onStashScreenExitStart() -> void: Subscreen.onStashScreenExitStart()
func onActiveToolAdded(CardUI: TbcUI) -> void: Subscreen.onActiveToolAdded(CardUI)
