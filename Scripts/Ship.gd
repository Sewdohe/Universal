extends RigidBody2D

class_name Ship

@onready var ThrusterLeft: GPUParticles2D = $ThrusterLeft
@onready var ThrusterRight: GPUParticles2D = $ThrusterRight
@onready var ThrustSound: AudioStreamPlayer = $ThrustSound
@onready var LaserSound: AudioStreamPlayer = $LaserSound
@onready var GunPosLeft: Marker2D = $GunPosLeft
@onready var GunPosRight: Marker2D = $GunPosRight
@onready var ShotTimer: Timer = $ShotTimer
@onready var Sprite: Sprite2D = $Ship
@onready var PhysicsBody: RigidBody2D = self
@onready var ShieldSprite: Sprite2D = $Shield
@onready var HealthBar: ProgressBar = $CanvasLayer/Control/ProgressBar
@onready var ShieldBar: ProgressBar = $CanvasLayer/Control/ProgressBar2

@export var rotation_speed: float = 0.20
@export var accel_strength: float = 100.0
@export var deceleration: float = 3.0
@export var shot_strength: float = 1.0
@export var health: float = 100.0
@export var shield_health: float = 200.0

var cloak_active = false
var shield_active = false
var targeting_active = false
var targetIndex = 0
var accelerating = false
var energy = 100.0
var shield_disabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
