extends LineEdit
var has_checked: bool = false
@onready var ItemNAME: String = get_parent().ItemNAME
func _on_text_submitted(__: String):
	release_focus()

func _on_focus_exited():
	if !has_checked and text.is_valid_int():
		if int(text) != 0 and !Helper.id_to_dict(int(text), ItemNAME):
			has_checked = true
		else:
			has_checked = false
			text = "" 
			AudioMaster.play_sfx("unconfirm_default")

func _on_text_changed(__: String): has_checked = false
