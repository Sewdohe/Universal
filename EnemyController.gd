extends RigidBody2D

@onready var GunPosLeft: Marker2D = $GunPosLeft
@onready var GunPosRight: Marker2D = $GunPosRight
@onready var LaserSound: AudioStreamPlayer = $LaserSound
@onready var ShotTimer: Timer = $ShotTimer
@onready var OnScreenNotifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var health = 100
var speed = 5
var look_speed = 0.1
var player_distance = 0.0
@export var persue_distance = 120
@export var persue = false

const BULLET = preload("res://Prefabs/bullet.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _integrate_forces(state):
	if(persue):
		if(player_distance < 100):
			apply_brakes(state)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Check for bullet hits
	var collisions = get_colliding_bodies()
	for collision in collisions:
		if (collision.is_in_group("Bullet")):
			take_damage(5)

	if(persue):
		var player = get_tree().get_nodes_in_group("Player")[0]
		player_distance = global_position.distance_to(player.position)
		if ( player_distance < persue_distance):
			persue_target(player.position)
			
			if (ShotTimer.time_left == 0):
				fire(rotation)
	
func fire(angle):
	var bullet_left = BULLET.instantiate()
	var bullet_right = BULLET.instantiate()
	bullet_left.global_transform = GunPosLeft.global_transform
	bullet_right.global_transform = GunPosRight.global_transform
	bullet_left.add_to_group("Bullet")
	bullet_right.add_to_group("Bullet")
	bullet_left.apply_central_impulse(Vector2(cos(angle), sin(angle)) * 30)
	bullet_right.apply_central_impulse(Vector2(cos(angle), sin(angle)) * 30)
	owner.add_child(bullet_left)
	owner.add_child(bullet_right)
	LaserSound.play()
	ShotTimer.start()
	ShotTimer.wait_time = randf_range(0.6, 2)

func take_damage(amount: float):
	health -= amount
	if (health < 0):
		queue_free()

func track_target(target):
	SmoothRotate.SmoothLookAtRigid(self, target, look_speed)
	
func persue_target(target_pos: Vector2):
	SmoothRotate.SmoothLookAtRigid(self, target_pos, 0.4)
	var angle = rotation
	if(player_distance > 20):
		apply_central_force(Vector2(cos(angle), sin(angle)) * speed)
	
func is_on_screen() -> bool:
	return OnScreenNotifier.is_on_screen()
	
func apply_brakes(state):
	var new_speed = state.linear_velocity.length()
	new_speed -= 0.8
	if new_speed < 0:
		new_speed = 0
	state.linear_velocity = state.linear_velocity.normalized() * new_speed
