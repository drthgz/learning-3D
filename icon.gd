extends Sprite2D

func _ready():
	#var num1 = 20
	#var num2 = "geko" # its immutable
	#print("Hello from sprite", num1)
	#
	#var num1 = 10
	#var num2 = 5
	#var result = num1 + num2
	#print(result)
	#
	#var vec2_a=Vector2(1,2)
	#var vec2_b=Vector2(3,4)
	#var vec2_result = vec2_a + vec2_b
	#print(vec2_result)
	#
	#var array1=[1,2,3]
	#var array2=[4,5,6]
	#var merged_array = array1+array2
	#print(merged_array)
	#
	#
	
	#var player_inventory = ["sword", "sheild"]
	#var chest_loot = ["gold", "potion"]
	#player_inventory += chest_loot
	#print(player_inventory)
	var num1 = 10
	var num2 = 7
	var results_num = num1 * num2
	print(results_num)
	
	
	
func _process(delta: float) -> void:
	#print("refreshing...", delta)
	pass
class Variant:
	static func type_name(type):
		match type:
			TYPE_NIL: return "null"
			TYPE_BOOL: return "bool"
			TYPE_INT: return "int"
