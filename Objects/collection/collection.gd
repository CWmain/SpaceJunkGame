extends Node2D
@onready var text_screen_shot = $ColorRect/TextScreenShot

var pixelCountingThread: Thread
var pixelCountingSemaphore: Semaphore
var pixelCountingMutex: Mutex
var exitThread: bool = false
var imageToCount: Image

@onready var collection_hit_box = $CollectionHitBox
@onready var sub_viewport = $SubViewport

#TODO: Update colour definitions when a new texture is made
#region Asteroid Colors
var red : Color = Color(1, 0, 0, 1)
var green : Color = Color(0, 0.7569, 0.1255, 1)
var blue : Color = Color(0, 0.5804, 1, 1)
#endregion

func _ready():
	pixelCountingMutex = Mutex.new()
	pixelCountingSemaphore = Semaphore.new()
	exitThread = false
	pixelCountingThread = Thread.new()
	pixelCountingThread.start(countRGBPixels)
	
func _exit_tree():
	# Set exit condition to true.
	pixelCountingMutex.lock()
	exitThread = true # Protect with Mutex.
	pixelCountingMutex.unlock()

	# Unblock by posting.
	pixelCountingSemaphore.post()

	# Wait until it exits.
	pixelCountingThread.wait_to_finish()
	
func _on_collection_hit_box_body_entered(_body):
	collectAsteroid()

func collectAsteroid() -> void:
	var toCollect : Array[Node2D] = collection_hit_box.get_overlapping_bodies()
	for ast in toCollect:
		var visualPoly: Polygon2D = ast.visual
		
		visualPoly.reparent(sub_viewport)
		visualPoly.position = Vector2(150,150)
		
		await RenderingServer.frame_post_draw
		print("Attempting to make image")
		var myImage : Image = sub_viewport.get_texture().get_image()
		
		#printAllPixels(myImage)
		pixelCountingMutex.lock()
		imageToCount = myImage
		pixelCountingMutex.unlock()
		pixelCountingSemaphore.post()

		#var screenshot = ImageTexture.create_from_image(myImage)
		visualPoly.reparent(ast)
		visualPoly.position = Vector2(0,0)
		#text_screen_shot.texture = screenshot

func countRGBPixels():
	while true:
		pixelCountingSemaphore.wait()
		pixelCountingMutex.lock()
		var shouldExit = exitThread
		pixelCountingMutex.unlock()
		
		if shouldExit: break
		
		pixelCountingMutex.lock()
		var asteroidMakeUp: Dictionary = {"r":0,"g":0,"b":0}
		for i in range(0,300):
			for j in range(0,300):
				var testColor : Color = imageToCount.get_pixel(i,j)
				if (cmpColors(red,testColor)):
					asteroidMakeUp["r"] += 1
				if (cmpColors(green,testColor)):
					asteroidMakeUp["g"] += 1
				if (cmpColors(blue,testColor)):
					asteroidMakeUp["b"] += 1

		for key in asteroidMakeUp.keys():
			print(key, ": ", asteroidMakeUp[key])
		pixelCountingMutex.unlock()
	
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

func cmpColors(x: Color, y: Color) -> bool:
	if (x.a8 != y.a8):
		return false
	if (x.r8 != y.r8):
		return false
	if (x.g8 != y.g8):
		return false
	if (x.b8 != y.b8):
		return false
	return true
