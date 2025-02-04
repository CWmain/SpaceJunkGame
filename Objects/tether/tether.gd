extends Node2D

var TETHER_DISTANCE = 600

var active: bool = false
var pull: bool = false

@export var SPEED: float = 300
@export var MIN_TETHER_DISTANCE = 10
@export var MAX_TETHER_DISTANCE = 600
@export var PULL_FORCE: float = 57600

var hook_target: Asteroid
@export var player_rocket: RigidBody2D
@export var tether: DampedSpringJoint2D

@export var forceDistribution: Curve

@onready var tether_hook = $"."
@onready var los = $LOS
@onready var tether_line = $TetherLine

func _physics_process(delta):

	# Resets tether if it goes beyond the set distance from player rocket
	# Checks for (active or pull) due to the distance_to function having stange behaviour 
	# when the tether hook is reset on the player_rocket
	if (to_local(player_rocket.position).length() > MAX_TETHER_DISTANCE and (active or pull)):
		print("Max distance reached")
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
		position += Vector2(0,-1).rotated(rotation) * SPEED * delta
	
	# Apply a force to the Asteroid to move it towards the player rocket
	# Apply a force to the player rocket to move it towards the asteroid
	# Since we use call_deferred to reparent on collision, need to check that it was been done
	if (pull and (get_parent() is Asteroid) ):
		
		# Get the vector from the tether to the player
		var tetherBaseVector : Vector2 = global_position.direction_to(player_rocket.position)
		var tetherLength: float = to_local(player_rocket.position).length()

		# Calculate the percentage force to apply
		var percentageToApply: float = forcePercentFromDistance(tetherLength)
		var forceAmount: float = percentageToApply * PULL_FORCE * delta
		
		#Contruct vector2 to apply force in the right direction
		var forceVector: Vector2 = tetherBaseVector*forceAmount
			
		# Apply force to asteroid
		var ast : Asteroid = get_parent()
		ast.apply_force(forceVector)
		
		#Apply force to player rocket
		player_rocket.apply_force(forceVector*-1)
	
	# If LOS is broken, than reset tether
	if (los.is_colliding()):
		print("Line of Sight broken")
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

func forcePercentFromDistance(distance: float) -> float:
	var percent = (distance-MIN_TETHER_DISTANCE)/MAX_TETHER_DISTANCE
	return forceDistribution.sample(percent)

func _on_body_entered(body):
	if (body == null):
		return
	
	active = false
	tether_hook.set_collision_layer(0)
	tether_hook.set_collision_mask(0)

	# Reparent to the asteroid
	call_deferred("reparent", body)
	pull = true
	
	#Apply line of sight raycast to asteroid
	los.set_target_position(player_rocket.position)
