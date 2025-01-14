extends Node2D

var asteroid = preload("res://Objects/asteroid/asteroid.tscn")
var def = preload("res://Objects/asteroid/base_asteroids/default.tres")
var star = preload("res://Objects/asteroid/base_asteroids/star.tres")

@export var pixelCounter: SubViewport

func _ready():
	assert(pixelCounter != null)

func _process(_delta):

	if get_tree().get_nodes_in_group("Asteroid").size() < 2:
		spawn_asteroid()

func spawn_asteroid():
	var newAsteroid: Asteroid = asteroid.instantiate()
	var newProperties: AsteroidProperties
	
	# We duplicate to avoid issues of editing the base shape
	if Global.rng.randf() > 0.5:
		newProperties = def.duplicate()
	else:
		newProperties = star.duplicate()



	#region Apply attributes to asteroid
	print(newAsteroid.area)
	newAsteroid.position = position
	newAsteroid.properties = newProperties

	get_tree().get_root().add_child(newAsteroid)
	print("Mass: ", newAsteroid.get_mass())
	
	pixelCounter.countPolygonPixels(newAsteroid.visual)
	
