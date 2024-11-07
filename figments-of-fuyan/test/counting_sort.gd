extends Node

func _ready() -> void:
	var a: Array = [5, 19, 11, 3, 13, 12, 21]
	var b: Array = []
	countingSort(a, b, a.max())
# k is max
func countingSort(a: Array, b: Array, k: int) -> void:
	var c: Array = []
	c.resize(k + 1)
	c.fill(0)
	
	b.resize(a.size())
	b.fill(0)
	
	for i in range(a.size()):
		c[a[i]] += 1
		
	for i in range(1, k + 1):
		c[i] += c[i - 1]
		
	for i in range(a.size()):
		b[c[a[i]] - 1] = a[i]
		c[a[i]] -= 1
		
	print(c)
