extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	var bodies = get_tree().get_nodes_in_group("StellarBody")
	apply_impulse(calculate_gravity_force(bodies))

func calculate_gravity_force(bodies) -> Vector2:
	var sum := Vector2.ZERO
	for body in bodies:
			var distance: Vector2 = body.position - position
			sum += body.mass * (distance / (distance.length_squared() * distance.length()))
	var gravity: Vector2 = 1.5 * sum
	return gravity
