extends Node

func _ready() -> void:
	#                0   1  2  3   4   5   6
	var arr: Array = [3, 5, 9, 10, 11, 22, 30]
	arr.sort()

	print(binarySearchRecursive(arr, 0, arr.size() - 1, 2))
	print(binarySearchRecursive(arr, 0, arr.size() - 1, 3))
	print(binarySearchRecursive(arr, 0, arr.size() - 1, 22))
	print(binarySearchRecursive(arr, 0, arr.size() - 1, 30))
	print(binarySearchRecursive(arr, 0, arr.size() - 1, 32))
	
	
func binarySearchRecursive(A: Array, p: int, k: int, x: int) -> Variant:
	var middle_index: int = (p + k) / 2
	if x == A[middle_index]: return middle_index
	if p < k:
		if x < A[middle_index]: return binarySearchRecursive(A, p, middle_index, x)
		return binarySearchRecursive(A, middle_index + 1, k, x)
	return null

func debug(p: int, k: int, middle_index: int) -> void:
	print("Start: " + str(p))
	print("End: " + str(k))
	print("Middle: " + str(middle_index))
	print()
