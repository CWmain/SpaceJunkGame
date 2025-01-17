extends Node2D


@onready var collection_hit_box = $CollectionHitBox

@export var myID : String = "ERROR"
@export var pixel_counter: SubViewport


func _ready():
	assert(myID != "ERROR")

func _process(_delta):
	pass
	

	
func _on_collection_hit_box_body_entered(_body):
	collectAsteroid()

func collectAsteroid() -> void:
	var toCollect : Array[Node2D] = collection_hit_box.get_overlapping_bodies()
	for ast in toCollect:
		# Prevents collection if the hook is still attached to the asteroid
		if ast.get_node_or_null("TetherHook") != null:
			continue
		
		var visualPoly: Polygon2D = ast.visual
		pixel_counter.countPolygonPixels(myID, visualPoly)
		
		# Free the asteroid
		ast.queue_free()
	
func printAllPixels(myImage: Image):
	var dict = {}
	for i in range(0,300):
		for j in range(0,300):
			if dict.has(myImage.get_pixel(i,j)):
				dict[myImage.get_pixel(i,j)] += 1
			else:
				dict[myImage.get_pixel(i,j)] = 1
	for key in dict.keys():
		if dict[key] > 200:
			print(key, ": ", dict[key])
	
