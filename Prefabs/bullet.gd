extends RigidBody2D

@onready var sprite = $Sprite2D
@onready var collison_shape = $CollisionShape2D

var collision_position

const EXPLOSION_EFFECT = preload("res://Effects/explosion_effect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _integrate_forces(state):
	var bodies = get_tree().get_nodes_in_group("StellarBody")
	apply_impulse(calculate_gravity_force(bodies))
	
	collision_position = state.get_contact_local_position(0)


func calculate_gravity_force(bodies) -> Vector2:
	var sum := Vector2.ZERO
	for body in bodies:
			var distance: Vector2 = body.position - position
			sum += body.mass * (distance / (distance.length_squared() * distance.length()))
	var gravity: Vector2 = 1.5 * sum
	return gravity

func _on_body_entered(body):
	var explosion = EXPLOSION_EFFECT.instantiate()
	add_child(explosion)
	explosion.global_position = collision_position
	explosion.emitting = true
	sprite.queue_free()
	collison_shape.queue_free()
	
