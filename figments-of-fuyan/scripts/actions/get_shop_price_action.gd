class_name GetShopPriceAction extends Action

var base_price: int
var shop: MapNodeGD

var final_price: int
var mults: Array
var adds: Array

func _init(_base_price: int = 0, _shop: MapNodeGD = null) -> void:
	super()
	base_price = _base_price
	shop = _shop
	
func onPreAction() -> void:
	pass
	
func onPostAction():
	for add in adds: base_price += add
	for mult in mults: base_price = int(float(base_price) * mult)
	final_price = max(base_price, 0)
	
func onAdd(value: int) -> void:
	adds.append(value)
	
func onMult(value: float) -> void:
	mults.append(value)
	
func getFinalPrice() -> int:
	return final_price

func getShop() -> MapNodeGD:
	return shop
