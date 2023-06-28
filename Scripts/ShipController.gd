extends RigidBody2D

@export var rotation_speed: float = 0.20
@export var accel_strength: float = 100.0
@export var deceleration: float = 3.0
@export var shot_strength: float = 1.0
@export var health: float = 100.0
@export var shield_health: float = 200.0

@onready var ThrusterLeft: GPUParticles2D = $ThrusterLeft
@onready var ThrusterRight: GPUParticles2D = $ThrusterRight
#@onready var Camera: Camera2D = $PlayerCam
@onready var ThrustSound: AudioStreamPlayer = $ThrustSound
@onready var LaserSound: AudioStreamPlayer = $LaserSound
@onready var GunPosLeft: Marker2D = $GunPosLeft
@onready var GunPosRight: Marker2D = $GunPosRight
@onready var LeftSide: Marker2D = $LeftSide
@onready var RightSide: Marker2D = $RightSide
@onready var ShotTimer: Timer = $ShotTimer
@onready var Sprite: Sprite2D = $Ship
@onready var Reticule: Sprite2D = $Reticule
@onready var PhysicsBody: RigidBody2D = self
@onready var CloakShader: ShaderMaterial = Sprite.get("material")
@onready var ShieldCollider: CollisionShape2D = $ShieldCollider
@onready var ShieldSprite: Sprite2D = $Shield
@onready var HealthBar: ProgressBar = $CanvasLayer/Control/ProgressBar
@onready var ShieldBar: ProgressBar = $CanvasLayer/Control/ProgressBar2

# Use this to control shader params
# print(CloakShader.get_shader_parameter("alpha"))

var cloak_active = false
var shield_active = false
var targeting_active = false
var targetIndex = 0
var accelerating = false
var energy = 100.0
var shield_disabled = false

const BULLET = preload("res://Prefabs/bullet.tscn")

func _process(delta):
	if Input.is_action_just_pressed("Fire"):
		if (ShotTimer.time_left == 0):
			fire(rotation)
	if Input.is_action_pressed("Strafe Left"):
		strafe_left()
	if Input.is_action_pressed("Strafe Right"):
		strafe_right()
	if Input.is_action_pressed('Right'):
		rotate_right()
	if Input.is_action_pressed('Left'):
		rotate_left()
	if Input.is_action_pressed('Accelerate'):
		accelerate()
	else:
		ThrusterLeft.emitting = false
		ThrusterRight.emitting = false
	if Input.is_action_just_pressed("Ability 1"):
		toggle_shield()
	if(shield_disabled):
		shield_active = false
		ShieldCollider.disabled = true
		ShieldSprite.visible = false

	# Set GUI element values
	HealthBar.value = health
	ShieldBar.value = shield_health
	

func _physics_process(delta):
	var collisions = get_colliding_bodies()
	if(!shield_active):
		for collision in collisions:
			if (collision.is_in_group("Bullet")):
				take_damage(10)
	elif(shield_active):
		for collision in collisions:
			if (collision.is_in_group("Bullet")):
				take_shield_damage(10)

func _integrate_forces(state):
	# apply the pulling effect from other bodies
	var bodies = get_tree().get_nodes_in_group("StellarBody")
	apply_impulse(calculate_gravity_force(bodies))
	
	if Input.is_action_pressed("Brake"):
		brake(state)

	if Input.is_action_pressed("Target"):
		manage_targets()
	else:
		Reticule.visible = false

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
	
func take_damage(amount: float):
	print("TAKING DAMAGE")
	health -= amount
	if (health < 0):
		queue_free()
		
func take_shield_damage(amount: float):
	shield_health -= amount
	if (shield_health < 0):
		shield_active = false
		shield_disabled = true
		
func accelerate():
	var angle = rotation
	ThrusterLeft.emitting = true
	ThrusterRight.emitting = true
	apply_central_force(Vector2(cos(angle), sin(angle)) * accel_strength)
	
func strafe_left():
	apply_central_force(global_transform.y * -50)

func strafe_right():
	apply_central_force(global_transform.y * 50)
	
func rotate_left():
	angular_velocity += rotation_speed * -1
func rotate_right():
	angular_velocity += rotation_speed
	
func toggle_shield():
	if(!shield_disabled):
			if(!shield_active):
				# turn shield and shield collider on
				shield_active = true
				ShieldCollider.disabled = false
				ShieldSprite.visible = true
			elif(shield_active):
				shield_active = false
				ShieldCollider.disabled = true
				ShieldSprite.visible = false
	elif(shield_disabled):
		print("shield_disabled")
		shield_active = false
		ShieldCollider.disabled = true
		ShieldSprite.visible = false

func brake(state):
	var new_speed = state.linear_velocity.length()
	new_speed -= deceleration
	if new_speed < 0:
		new_speed = 0
	state.linear_velocity = state.linear_velocity.normalized() * new_speed
	
func manage_targets():
	var potential_targets = get_tree().get_nodes_in_group("Targetable")
	var closest_target
	var targets = []
	var maxIndex;
	for target in potential_targets:
		var target_data = {
			"distance": global_position.distance_to(target.global_position),
			"target": target
		}
		var on_screen: bool = target.find_child("VisibleOnScreenNotifier2D").is_on_screen()
		if(on_screen):
			targets.push_front(target_data)
	maxIndex = len(targets) - 1
	
	if Input.is_action_just_pressed("Target Cycle Left"):
		targetIndex -= 1
		if(targetIndex < 0):
			targetIndex = maxIndex
	if Input.is_action_just_pressed("Target Cycle Right"):
		targetIndex += 1
		if(targetIndex > maxIndex):
			targetIndex = 0
	targets.sort_custom(func(a,b): return a.distance < b.distance)
	if(len(targets)):
		SmoothRotate.SmoothLookAtRigid(self, targets[targetIndex].target.position, 0.1)
		Reticule.visible = true
		Reticule.global_position = targets[targetIndex].target.global_position
	else:
		Reticule.visible = false
