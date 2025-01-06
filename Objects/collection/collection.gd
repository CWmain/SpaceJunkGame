extends Node2D
@onready var text_screen_shot = $ColorRect/TextScreenShot

#region Variables for the pixel counting thread
var pixelCountingThread: Thread
var pixelCountingSemaphore: Semaphore
var pixelCountingMutex: Mutex
var exitThread: bool = false
var imageToCount: Image
#endregion

var scoreMutex: Mutex
var scoreUpdate: bool = false
var score: Dictionary = {"r":0,"g":0,"b":0}

@onready var collection_hit_box = $CollectionHitBox
@onready var sub_viewport = $SubViewport

@onready var scoreSign = $Sign

#TODO: Update colour definitions when a new texture is made
#region Asteroid Colors
var red : Color = Color(1, 0, 0, 1)
var green : Color = Color(0, 0.7569, 0.1255, 1)
var blue : Color = Color(0, 0.5804, 1, 1)
#endregion

func _ready():
	# Initialise all variables needed for the pixel counting thread
	pixelCountingMutex = Mutex.new()
	pixelCountingSemaphore = Semaphore.new()
	pixelCountingThread = Thread.new()
	pixelCountingThread.start(countRGBPixels)
	exitThread = false
	
	scoreMutex = Mutex.new()

func _process(_delta):
	if scoreUpdate:
		scoreMutex.lock()
		scoreSign.label.set_text(str(score))
		scoreUpdate = false
		scoreMutex.unlock()
	if Input.is_action_just_pressed("PlacePoint"):
		print(score)
	
func _exit_tree():
	# Set exit condition to true.
	pixelCountingMutex.lock()
	exitThread = true 
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
		# Prevents collection if the hook is still attached to the asteroid
		if ast.get_node_or_null("TetherHook") != null:
			continue
		
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

		# Reparents the visual polygon back to its original owner (Asteroid)
		visualPoly.reparent(ast)
		visualPoly.position = Vector2(0,0)

		# Free the asteroid
		ast.queue_free()

		# Generates a screednshot for visual clarity on the subviewport
		var screenshot = ImageTexture.create_from_image(myImage)
		text_screen_shot.texture = screenshot

## NOTE: Variable passed to countRGBPixels by the imageToCount global variable
## Threaded function which returns the red, green, blue pixel count of imageToCount
func countRGBPixels() -> void:
	while true:
		pixelCountingSemaphore.wait()
		pixelCountingMutex.lock()
		var shouldExit = exitThread
		pixelCountingMutex.unlock()
		
		if shouldExit: break
		
		#Store locally to decrease the time locked
		pixelCountingMutex.lock()
		var localImageToCount: Image = imageToCount.duplicate()
		pixelCountingMutex.unlock()
		var asteroidMakeUp: Dictionary = {"r":0,"g":0,"b":0}
		for i in range(0,300):
			for j in range(0,300):
				var testColor : Color = localImageToCount.get_pixel(i,j)
				if (cmpColors(red,testColor)):
					asteroidMakeUp["r"] += 1
				if (cmpColors(green,testColor)):
					asteroidMakeUp["g"] += 1
				if (cmpColors(blue,testColor)):
					asteroidMakeUp["b"] += 1

		scoreMutex.lock()
		for key in asteroidMakeUp.keys():
			score[key] += asteroidMakeUp[key]
			print(key, ": ", asteroidMakeUp[key])
		scoreUpdate = true
		scoreMutex.unlock()
	
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
