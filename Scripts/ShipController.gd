extends RigidBody2D

@export var rotation_speed: float = 0.15
@export var accel_strength: float = 100.0
@export var deceleration: float = 3.0

@onready var ThrusterLeft: GPUParticles2D = $ThrusterLeft
@onready var ThrusterRight: GPUParticles2D = $ThrusterRight
@onready var Camera: Camera2D = $PlayerCam
@onready var ThrustSound: AudioStreamPlayer = $ThrustSound
@onready var LaserSound: AudioStreamPlayer = $LaserSound
@onready var GunPosLeft: Marker2D = $GunPosLeft
@onready var GunPosRight: Marker2D = $GunPosRight
@onready var ShotTimer: Timer = $ShotTimer

const BULLET = preload("res://Prefabs/bullet.tscn")

const zoom_speed = 0.05
	
func _process(delta):
	if Input.is_action_just_pressed("Fire"):
		if (ShotTimer.time_left == 0):
			fire(rotation)
	print(ShotTimer.time_left)

func _physics_process(delta):
	if Input.is_action_pressed('Right'):
		angular_velocity += rotation_speed
	if Input.is_action_pressed('Left'):
		angular_velocity += rotation_speed * -1
	if Input.is_action_pressed('ZoomIn'):
		Camera.zoom += Vector2(zoom_speed, zoom_speed)
	if Input.is_action_pressed('ZoomOut'):
		Camera.zoom -= Vector2(zoom_speed, zoom_speed)
	if Input.is_action_pressed('Accelerate'):
		var angle = rotation
		ThrusterLeft.emitting = true
		ThrusterRight.emitting = true
		apply_central_force(Vector2(cos(angle), sin(angle)) * accel_strength)
	else:
		ThrusterLeft.emitting = false
		ThrusterRight.emitting = false
		
	# apply the pulling effect from other bodies
	var bodies = get_tree().get_nodes_in_group("StellarBody")
	apply_impulse(calculate_gravity_force(bodies))

func _integrate_forces(state):
	if Input.is_action_pressed("Brake"):
		var new_speed = state.linear_velocity.length()
		new_speed -= deceleration
		if new_speed < 0:
			new_speed = 0
		state.linear_velocity = state.linear_velocity.normalized() * new_speed

func calculate_gravity_force(bodies) -> Vector2:
	var sum := Vector2.ZERO
	for body in bodies:
			var distance: Vector2 = body.position - position
			sum += body.mass * (distance / (distance.length_squared() * distance.length()))
	var gravity: Vector2 = 1.5 * sum
	return gravity

func fire(angle):
	var bullet_left = BULLET.instantiate()
	var bullet_right = BULLET.instantiate()
	bullet_left.global_position = GunPosLeft.global_position
	bullet_right.global_position = GunPosRight.global_position
	bullet_left.apply_central_force(Vector2(cos(angle), sin(angle)) * 10000)
	bullet_right.apply_central_force(Vector2(cos(angle), sin(angle)) * 10000)
	owner.add_child(bullet_left)
	owner.add_child(bullet_right)
	LaserSound.play()
	ShotTimer.start()
