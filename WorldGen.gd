extends Control

@onready var generator = $BackgroundGenerator

var new_size = Vector2(1000, 1000)

func _generate_new():
	generator.custom_minimum_size = new_size
	generator.size = new_size
	generator.set_mirror_size(new_size)
	
	var aspect = Vector2(1,1)
	if new_size.x > new_size.y:
		aspect = Vector2(new_size.y / new_size.x, 1.0)
	else:
		aspect = Vector2(1.0, new_size.x / new_size.y)
	
#	$HBoxContainer/Control/TextureRect.size = aspect * 600

#	await get_tree().idle_frame
#	$HBoxContainer/Control/TextureRect.size = Vector2(600,600)
	generator.generate_new()

func _ready():
	randomize()
	_generate_new()

