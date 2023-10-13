extends Control

@onready var Buttons: Control = $Buttons
@onready var AnimationItem: Sprite2D = $AnimationItem
@onready var MoveScreen: AnimationPlayer = $MoveScreen

var info: Array = []
var theme_based: Array = str_to_var(Helper.return_file_contents("res://static/ui_general/theme_based.txt").split("\n")[1])[Settings.equipped_theme]

func _ready() -> void:
	AnimationItem.visible = false
	
func setup_buttons(screen_change: Array) -> void:
	for button in Buttons.get_children(): button.queue_free()
	info = []
	var position_buttons: Array = []
	for i in screen_change:
		var control := Control.new()
		Buttons.add_child(control)
		control.name = i[0]
		
		var button := TextureButton.new()
		control.add_child(button)
		button.texture_normal = load("res://scenes/ui_general/menu_buttons/" + str(Settings.equipped_theme) + "/menu_button_sprite.png")
		Helper.create_button_clickmask(button) 
		
		var label := Label.new()
		label.text = i[0]
		label.label_settings = preload("res://scenes/ui_general/menu_buttons/menu_button_label_settings.tres")
		control.add_child(label)
		
		if i[2] in [1,2]: button.flip_h = true
		match typeof(i[1]):
			TYPE_STRING: if !i[1].is_empty(): info.append([button, i[1]])
			TYPE_CALLABLE: button.pressed.connect(i[1])
		position_buttons.append([control, i[2]])
		
		label.position = Vector2(theme_based[i[2]].x, theme_based[i[2]].y)
		label.size = Vector2(theme_based[i[2]].z, theme_based[i[2]].w)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var ly: int = 540
	var ry: int = 540
	for i in position_buttons:
		match i[1]:
			0: ly -= 105
			1: ry -= 105
			
	var loffset: int = 0
	var lys: int = 0
	
	var rys: int = 0
	var roffset: int = 0
	
	for i in position_buttons:
		match i[1]:
			0:
				i[0].position = Vector2(loffset, lys + ly)
				lys += 200
				loffset = 0 if loffset == -100 else -100
			1:
				i[0].position = Vector2(1200 + roffset, rys + ry)
				rys += 200
				roffset = 0 if roffset == 100 else 100
			2: 
				i[0].position = Vector2(1500, 820)

func play_animation(screen_file_path: String, backwards: bool) -> void:
	var button: TextureButton = info.filter(func(x: Array): return x[1] == screen_file_path)[0][0]
	button.get_parent().visible = false
	AnimationItem.position = Vector2(button.position.x, button.position.y)
	AnimationItem.flip_h = button.flip_h
	if !backwards: MoveScreen.play("move_screen")
	else: MoveScreen.play_backwards("move_screen")
