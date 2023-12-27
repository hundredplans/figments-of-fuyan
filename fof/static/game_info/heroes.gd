extends Node
const hid_primary_color: Dictionary = {
	1: "386b3c",
}

const hid_accent_color: Dictionary = {
	1: "ce8e67",
}

const hid_description: Dictionary = {
	1: "- Simple\n- Brawler\n- Individualist"
}

func id_to_hid(id: int) -> int:
	if id in range(105, 113): return 1
	return 0

func hid_to_id(hid: int, level: int) -> int:
	match hid:
		1: return 105 + level
	return 0
	
func hid_to_base(hid: int) -> int:
	return hid_to_id(hid, 0)
	
func id_to_base(id: int) -> int:
	return hid_to_base(id_to_hid(id))
