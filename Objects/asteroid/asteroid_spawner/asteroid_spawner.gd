extends Node2D

var asteroid = preload("res://Objects/asteroid/asteroid.tscn")
var shape = preload("res://Objects/asteroid/base_asteroids/default.tres")

func _process(delta):

	if get_tree().get_nodes_in_group("Asteroid").size() < 2:
		var newAsteroid: Asteroid = asteroid.instantiate()
		var newProperties: AsteroidProperties = shape.duplicate()

		get_tree().get_root().add_child(newAsteroid)

		#region Apply attributes to asteroid
		print(newAsteroid.area)
		newAsteroid.position = position
		newAsteroid.properties = newProperties
		newAsteroid.area = 1001
		newAsteroid.mass = 100
		print("Mass: ", newAsteroid.get_mass())

