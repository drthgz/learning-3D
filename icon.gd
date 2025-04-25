extends Sprite2D

func _ready():
	#var health = 49
	#var ammo = 10
	#
	#print(health>50)
	#if health >50 and ammo >0:
		#print("Your ready to fight!!")
	#else:
		#print("You need health or ammo to fight...")
	#var has_key=false
	#var is_door_unlocked=false
	#if has_key or is_door_unlocked:
		#print("You can enter the room")
	#else:
		#print("You need a key to unlock the door")
	#var enemy_alive = true
	#if not enemy_alive:
		#print("The the enemy is defeated")
	#else:
		#print("Enemy is still alive")
		
	#var has_sword = true
	#var has_sheild = false
	#var is_safe = not has_sword and has_sheild or has_sword
	#if is_safe:
		#print("you are safe. you can survive")
	#else:
		#print("you are in danger")
		
	#var inventory = ["sword", "sheild", "potion"]
	#if "sword" in inventory:
		#print("You hav a sword!")
	#else:
		#print("you don't have a sword")
	#var level=10
	#if level==5:
		#print("You have reached level 5")
	#var score = 100
	#if score !=0:
		#print("keep going!")
	var player_health = 45
	if player_health >= 50:
		print("Low health, you need to find a potion!")
	
	
	
func _process(delta: float) -> void:
	#print("refreshing...", delta)
	pass
class Variant:
	static func type_name(type):
		match type:
			TYPE_NIL: return "null"
			TYPE_BOOL: return "bool"
			TYPE_INT: return "int"
