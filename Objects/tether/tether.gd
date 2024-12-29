extends Node2D

var SPEED = 5
var TETHER_FORCE = 10
var active: bool = false
var pull: bool = false

@export var player_rocket: RigidBody2D
@export var tether: DampedSpringJoint2D

@onready var tether_hook = $"."
@onready var los = $LOS

func _physics_process(_delta):
	if (active):
		print(rotation)
		position += Vector2(0,-1).rotated(rotation) * SPEED
	
	if (pull):
		#Apply line of sight raycast to player rocket
		los.set_target_position(to_local(player_rocket.position))
		#los.rotation = to_global(los.position).angle_to(player_rocket.position)-rotation
	if (los.is_colliding()):
		reset_tether()

func fire_tether():
	# Do nothing if already pulling as that means it was already been fired
	if (pull):
		return

	reparent(get_tree().root)
	active = true
	
	tether_hook.set_collision_layer(4)
	los.set_enabled(true)
	tether_hook.set_collision_mask(4)

func reset_tether():
	#get_parent().set_lock_rotation_enabled(true)
	tether_hook.set_collision_layer(0)
	los.set_enabled(false)
	tether_hook.set_collision_mask(0)
	reparent(player_rocket)
	rotation = 0
	position = Vector2.ZERO
	active = false
	pull = false
	tether.node_b = ""

func _on_body_entered(body):
	if (body == null):
		return
	active = false
	tether_hook.set_collision_layer(0)
	tether_hook.set_collision_mask(0)
	#body.set_lock_rotation_enabled(false)
	print(body.is_lock_rotation_enabled())
	
	# Reparent to the asteroid
	reparent(body)
	pull = true
	
	# Attach Tether to Asteroid
	tether.node_b = body.get_path()
	
	#Apply line of sight raycast to asteroid
	los.set_target_position(player_rocket.position)
	
	print("Do Tether Stuff")
