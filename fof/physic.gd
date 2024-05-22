extends Node

func _ready() -> void:
	var zarowka_a_voltage: Array = [2.03, 4.05, 6.03, 7.94, 9.98, 11.95, 13.94, 15.95, 17.85, 19.85, 21.80, 23.80]
	var zarowka_b_voltage: Array = [1.80, 4.00, 5.90, 7.90, 9.80, 11.80, 13.90, 15.80, 17.80, 19.80, 21.80, 23.80]
	var opor_a_voltage: Array = [2.01, 4.04, 6.00, 7.96, 9.96, 11.94, 13.98, 15.94, 17.95, 19.87, 21.80, 23.80]
	var opor_b_voltage: Array = [1.90, 3.90, 5.80, 7.80, 9.80, 11.70, 13.70, 15.70, 17.60, 19.60, 21.80, 23.80]
	
	var zarowka_a_current: Array = [0.29, 0.38, 0.45, 0.52, 0.57, 0.63, 0.68, 0.73, 0.77, 0.82, 0.86, 0.90]
	var zarowka_b_current: Array = [0.29, 0.38, 0.45, 0.52, 0.58, 0.63, 0.68, 0.73, 0.77, 0.82, 0.86, 0.90]
	var opor_a_current: Array = [18.60, 37.50, 55.60, 73.80, 92.20, 106.60, 121.00, 137.10, 164.60, 0.18, 0.19, 0.22]
	var opor_b_current: Array = [17.60, 35.30, 53.40, 71.60, 89.20, 107.50, 116.50, 133.50, 149.80, 167.10, 0.20, 0.21]
	#
	#print(getResistanceInaccuracy(
		#getCurrentInaccuracyZarowka(zarowka_a_current),
		#zarowka_a_current,
		#getVoltageInaccuracy(zarowka_a_voltage),
		#zarowka_a_voltage
	#))
	
	#print(getResistanceInaccuracy(
		#getCurrentInaccuracyZarowka(zarowka_b_current),
		#zarowka_b_current,
		#getVoltageInaccuracy(zarowka_b_voltage),
		#zarowka_b_voltage
	#))
	
	#print(getResistanceInaccuracy(
		#getCurrentInaccuracyOpor(opor_a_current),
		#opor_a_current,
		#getVoltageInaccuracy(opor_a_voltage),
		#opor_a_voltage
	#))
	#
	#print(getResistanceInaccuracy(
		#getCurrentInaccuracyOpor(opor_b_current),
		#opor_b_current,
		#getVoltageInaccuracy(opor_b_voltage),
		#opor_b_voltage
	#))
	
	#print(getCurrentInaccuracyZarowka(zarowka_a_current))
	#print(getResistanceInaccuracy(
		#[0.06],
		#[0.28],
		#[0.02],
		#[2.02]
	#))
	
	yolo(getCurrentInaccuracyZarowka(zarowka_a_current), getVoltageInaccuracy(zarowka_a_voltage), zarowka_a_current, zarowka_a_voltage)
	
func getVoltageInaccuracy(arr: Array) -> Array:
	var narr: Array = []
	for i in range(arr.size()):
		var mult: float = 0.01 if arr.size() - 2 > i else 0.1
		narr.append((0.005 * arr[i]) + mult)
	return narr

func getCurrentInaccuracyZarowka(arr: Array) -> Array:
	var narr: Array = []
	for i in range(arr.size()):
		narr.append(((0.008 * arr[i]) + 0.001))
	return narr

func getCurrentInaccuracyOpor(arr: Array) -> Array: # Changes based on whether val is < 1
	var narr: Array = []
	for i in range(arr.size()):
		if arr[i] < 1: narr.append((0.005 * arr[i]) + 0.01)
		else: narr.append((0.005 * arr[i]) + 0.1)
	return narr

func getResistanceInaccuracy(current_inaccuracy_arr: Array, current_arr: Array, voltage_inaccuracy_arr: Array, voltage_arr: Array) -> Array:
	var arr: Array = []
	for i in range(current_arr.size()):
		var Id: float = current_inaccuracy_arr[i] / 1000
		var I: float = current_arr[i] / 1000
		var Vd: float = voltage_inaccuracy_arr[i] 
		var V: float = voltage_arr[i]
		
		print(current_inaccuracy_arr[i])
		print("ΩI: " + str(Id))
		print("ΩV: " + str(Vd))
		print("V: " + str(V))
		print("I: " + str(I))
		print()
		# make sure that the results that change from A to mA dont mess this up
		arr.append(
			(V / I) * sqrt(pow(Vd / V,2) + pow(Id / I,2))
		)
		#arr.append(\
			#sqrt(
				#pow(Vd / I, 2) + 
				#pow(-(V * Id / pow(I, 2)), 2)
			#) * 1000)
	return arr
	
func yolo(cur_inacc: Array, volt_inacc: Array, cur: Array, volt: Array) -> void:
	var Ui_array: Array = cur_inacc.map(func(x: float): return x / sqrt(3))
	var Uv_array: Array = volt_inacc.map(func(x: float): return x / sqrt(3))
	var dR_array: Array = []
	for i in range(Ui_array.size()):
		var V: float = volt[i]
		var I: float = cur[i]
		var Ud: float = volt_inacc[i]
		var Id: float = cur_inacc[i]
		var Ui: float = Ui_array[i]
		var Uv: float = Uv_array[i]
		var Ru: float = I * Ud
		var Ri: float = V * Id
		var R: float = sqrt(pow(Ru,2) + pow(Ri, 2))
		dR_array.append(abs((R / Ud) * Uv) + abs(R / Id) * Ui)
	print(dR_array)
