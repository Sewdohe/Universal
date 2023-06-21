extends CharacterBody2D


var speed = 80  # move speed in pixels/sec
var rotation_speed = 1.5  # turning speed in radians/sec

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	var move_input = Input.get_action_strength("Accelerate")
	var rotation_direction = Input.get_axis("Left", "Right")
	velocity = transform.x * move_input * speed
	rotation += rotation_direction * rotation_speed * delta
	move_and_slide()
