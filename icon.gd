extends Sprite2D

func _ready():
	#var conditon = false
	#if conditon or check_function():
		#print("either condition is True!")
	#else:
		#print("Neither is true")

	#var my_array = []
	#var index =1
	#print(my_array.size())
	#if index <my_array.size() and my_array[index] == 10:
		#print("Found 10 at index 1")
	#else:
		#print("Index out of bound error")
#
#func check_function():
	#print("The check functon has been called")
	#return true
	
	#var inventory = ["sword", "sheild"]
	#if inventory:
		#print("you have items in your inventory")
	#else:
		#print("You have nothing")
		
	var enemies_to_spawn=[Vector2(100,200), Vector2(300,400)]
	if enemies_to_spawn:
		print("Enemies are waiting to be spawn")
	else:
		print("All enemies have been spawned")
	
	
func _process(delta: float) -> void:
	#print("refreshing...", delta)
	pass
class Variant:
	static func type_name(type):
		match type:
			TYPE_NIL: return "null"
			TYPE_BOOL: return "bool"
			TYPE_INT: return "int"
