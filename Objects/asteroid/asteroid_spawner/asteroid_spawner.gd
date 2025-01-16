extends Node2D

var asteroid = preload("res://Objects/asteroid/asteroid.tscn")
var def = preload("res://Objects/asteroid/base_asteroids/default.tres")
var star = preload("res://Objects/asteroid/base_asteroids/star.tres")

var myID : String = "Spawner"

@export var pixelCounter: SubViewport

func _ready():
	assert(pixelCounter != null)

func _process(_delta):
	pass

func spawn_asteroid():
	var newAsteroid: Asteroid = asteroid.instantiate()
	var newProperties: AsteroidProperties
	
	# We duplicate to avoid issues of editing the base shape
	if Global.rng.randf() > 0.5:
		newProperties = def.duplicate()
	else:
		newProperties = star.duplicate()

	# Randomise the texture offset and rotation
	newProperties.textureOffest = Vector2(round(Global.rng.randf_range(0,255)),round(Global.rng.randf_range(0,255)))
	newProperties.textureRotation = round(Global.rng.randf_range(0,360))

	#region Apply attributes to asteroid
	print(newAsteroid.area)
	newAsteroid.position = position
	newAsteroid.properties = newProperties

	get_tree().get_root().add_child(newAsteroid)
	print("Mass: ", newAsteroid.get_mass())
	
	pixelCounter.countPolygonPixels(myID, newAsteroid.visual)
	
	# Slightly Randomise impluse direction (from +-PI/4)	
	newAsteroid.apply_impulse(Vector2(0,300).rotated(Global.rng.randf_range(-PI/4, PI/4)))


func _on_timer_timeout():
	if get_tree().get_nodes_in_group("Asteroid").size() < 20:
		spawn_asteroid()
