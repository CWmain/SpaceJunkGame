extends Node2D

var SPEED = 5
var TETHER_FORCE = 10
var TETHER_DISTANCE = 600

var active: bool = false
var pull: bool = false

@export var player_rocket: RigidBody2D
@export var tether: DampedSpringJoint2D

@onready var tether_hook = $"."
@onready var los = $LOS
@onready var tether_line = $TetherLine

func _physics_process(_delta):

	# Resets tether if it goes beyond the set distance from player rocket
	# Checks for (active or pull) due to the distance_to function having stange behaviour 
	# when the tether hook is reset on the player_rocket
	if (player_rocket.position.distance_to(position) > TETHER_DISTANCE and (active or pull)):
		reset_tether()
		
	# Set raycast so it is always pointing to player ship
	los.set_target_position(to_local(player_rocket.position))
	
	# Set tether graphic to always attach to player ship
	if (active or pull):
		var pointsToShip = PackedVector2Array([Vector2(0,0),to_local(player_rocket.position)])
		tether_line.set_points(pointsToShip)
	# When reset on the player ship, have empty points
	else:
		tether_line.set_points(PackedVector2Array())
	
	# State where tether hook is shot and is travelling
	if (active):
		position += Vector2(0,-1).rotated(rotation) * SPEED
	
	# If LOS is broken, than reset tether
	if (los.is_colliding()):
		reset_tether()

func fire_tether():
	# Do nothing if already pulling as that means it was already been fired
	if (pull):
		return
	tether_line.show()
	reparent(get_tree().root)
	active = true
	
	tether_hook.set_collision_layer(4)
	tether_hook.set_collision_mask(4)
	los.set_enabled(true)

func reset_tether():
	print("Reseting Tether")
	tether_line.hide()
	tether_hook.set_collision_layer(0)
	tether_hook.set_collision_mask(0)
	los.set_enabled(false)
	
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

	# Reparent to the asteroid
	reparent(body)
	pull = true
	
	# Attach Tether to Asteroid
	tether.node_b = body.get_path()
	
	#Apply line of sight raycast to asteroid
	los.set_target_position(player_rocket.position)
