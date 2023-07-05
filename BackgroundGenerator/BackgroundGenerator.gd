extends Control

@onready var background = $CanvasLayer/Background
@onready var starstuff = $StarStuff
@onready var nebulae = $Nebulae
@onready var particles = $StarParticles
@onready var starcontainer = $StarContainer
@onready var planetcontainer = $PlanetContainer
@onready var planet_scene = preload("res://BackgroundGenerator/Planet.tscn")
@onready var big_star_scene = preload("res://BackgroundGenerator/BigStar.tscn")

var should_tile = true
var reduce_background = false
var mirror_size = Vector2(200, 200)

@export var colorscheme :GradientTexture2D
var planet_objects = []
var star_objects = []

func _ready():
	pass

func set_mirror_size(new):
	mirror_size = new

func toggle_tile():
	should_tile = !should_tile
	starstuff.material.set_shader_parameter("should_tile", should_tile)
	nebulae.material.set_shader_parameter("should_tile", should_tile)
	
	_make_new_planets()
	_make_new_stars()

func generate_new():
	starstuff.material.set_shader_parameter("seed", randf_range(1.0, 10.0))
	starstuff.material.set_shader_parameter("pixels", max(size.x, size.y))
	
	var aspect = Vector2(1,1)
	if size.x > size.y:
		aspect = Vector2(size.x / size.y, 1.0)
	else:
		aspect = Vector2(1.0, size.y / size.x)
	
	starstuff.material.set_shader_parameter("uv_correct", aspect)
	nebulae.material.set_shader_parameter("seed", randf_range(1.0, 10.0))
	nebulae.material.set_shader_parameter("pixels", max(size.x, size.y))
	nebulae.material.set_shader_parameter("uv_correct", aspect)
	
	particles.speed_scale = 1.0
	particles.amount = 2
	particles.position = size * 0.5
	particles.process_material.set_shader_parameter("emission_box_extents", Vector3(size.x * 0.5, size.y*0.5,1.0))
	
	var p_amount = (size.x * size.y) / 150
	particles.amount = randi()%(int(p_amount * 0.75)) + int(p_amount * 0.25)

	$PauseParticles.start()
	
	_make_new_planets()
	_make_new_stars()

func _make_new_stars():
	for s in star_objects:
		s.queue_free()
	star_objects = []
	
	var star_amount = int(max(size.x, size.y) / 20)
	star_amount = max(star_amount, 1)
	for i in randi()%star_amount:
		_place_big_star()
	
func _make_new_planets():
	for p in planet_objects:
		p.queue_free()
	planet_objects = []

	var planet_amount = 5 #int(size.x * size.y) / 8000
	for i in randi()%planet_amount:
		_place_planet()

func _set_new_colors(new_scheme, new_background):
	colorscheme = new_scheme

	starstuff.material.set_shader_parameter("colorscheme", colorscheme)
	nebulae.material.set_shader_parameter("colorscheme", colorscheme)
	nebulae.material.set_shader_parameter("background_color", new_background)
	
	particles.process_material.set_shader_parameter("colorscheme", colorscheme)
	for p in planet_objects:
		p.material.set_shader_parameter("colorscheme", colorscheme)
	for s in star_objects:
		s.material.set_shader_parameter("colorscheme", colorscheme)

func _place_planet():
	var min_size = min(size.x, size.y)
	var scale = Vector2(1,1)*(randf_range(0.2, 0.7)*randf_range(0.5, 1.0)*min_size*0.005)
	
	var pos = Vector2()
	if (should_tile):
		var offs = scale.x * 100.0 * 0.5
		pos = Vector2(int(randf_range(offs, size.x - offs)), int(randf_range(offs, size.y - offs)))
	else:
		pos = Vector2(int(randf_range(0, size.x)), int(randf_range(0, size.y)))
	
	var planet = planet_scene.instantiate()
	planet.scale = scale
	planet.position = pos
	planetcontainer.add_child(planet)
	planet_objects.append(planet)

func _place_big_star():
	var pos = Vector2()
	if (should_tile):
		var offs = 10.0
		pos = Vector2(int(randf_range(offs, size.x - offs)), int(randf_range(offs, size.y - offs)))
	else:
		pos = Vector2(int(randf_range(0, size.x)), int(randf_range(0, size.y)))
	
	var star = big_star_scene.instantiate()
	star.position = pos
	starcontainer.add_child(star)
	star_objects.append(star)

func _on_PauseParticles_timeout():
	particles.speed_scale = 0.0

func set_background_color(c):
	background.color = c
	nebulae.material.set_shader_parameter("background_color", c)
