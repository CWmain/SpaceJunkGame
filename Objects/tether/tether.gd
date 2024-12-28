extends Node2D

var SPEED = 5
var TETHER_FORCE = 10
var active: bool = false
var pull: bool = false
@export var player_rocket: RigidBody2D
@onready var tether_hook = $"."

func _physics_process(_delta):
	if (active):
		position += Vector2(0,-1)*SPEED
	
	if (pull):
		var collidedAsteroid = get_parent()
		# Get a vector to move from current position towards ship
		var asteroidPosition : Vector2 = collidedAsteroid.position
		var shipPosition: Vector2 = player_rocket.position

		# TODO: Adjust how shift is calculated to get the asteroid moving towards the ship correctly
		# Consider shooting a physics object which stores the asteroid you want to pull, it breaks beyond a certain distance
		var shift : Vector2 = (shipPosition-asteroidPosition) * TETHER_FORCE

		collidedAsteroid.apply_force(shift, position)
	

func fire_tether():
	# Do nothing if already pulling as that means it was already been fired
	if (pull):
		return
	active = true
	
	tether_hook.set_collision_layer(4)
	tether_hook.set_collision_mask(4)

func reset_tether():
	get_parent().set_lock_rotation_enabled(true)
	tether_hook.set_collision_layer(0)
	tether_hook.set_collision_mask(0)
	reparent(player_rocket)
	position = Vector2.ZERO
	active = false
	pull = false

func _on_body_entered(body):
	if (body == null):
		return
	active = false
	tether_hook.set_collision_layer(0)
	tether_hook.set_collision_mask(0)
	body.set_lock_rotation_enabled(false)
	print(body.is_lock_rotation_enabled())
	
	# Reparent to the asteroid
	reparent(body)
	pull = true
	
	print("Do Tether Stuff")
