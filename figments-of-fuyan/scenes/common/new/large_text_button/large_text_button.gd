extends DefaultButton

@export var area_id: int

func setAreaID(_area_id: int) -> void:
	area_id = _area_id
	var area_info: AreaInfo = Helper.getFofInfoID(AreaInfo, area_id)
	BASE_COLOR = area_info.getAreaColor()
	HOVER_COLOR = area_info.getSecondAreaColor()
	DISABLED_COLOR = area_info.getThirdAreaColor()
