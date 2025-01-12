extends SubViewport

#region Variables for the pixel counting thread
var pixelCountingThread: Thread
var pixelCountingSemaphore: Semaphore
var pixelCountingMutex: Mutex
var exitThread: bool = false
var imageToCount: Image
#endregion

var scoreMutex: Mutex
var scoreUpdate: bool = false
signal scoreSignal
var score: Dictionary = {"r":0,"g":0,"b":0}

#TODO: Update colour definitions when a new texture is made
#region Asteroid Colors
var red : Color = Color(1, 0, 0, 1)
var green : Color = Color(0, 0.7569, 0.1255, 1)
var blue : Color = Color(0, 0.5804, 1, 1)
#endregion

@onready var sub_viewport = $"."


func _ready():
	# Initialise all variables needed for the pixel counting thread
	pixelCountingMutex = Mutex.new()
	pixelCountingSemaphore = Semaphore.new()
	pixelCountingThread = Thread.new()
	pixelCountingThread.start(countRGBPixels)
	exitThread = false
	
	scoreMutex = Mutex.new()

func _exit_tree():
	# Set exit condition to true.
	pixelCountingMutex.lock()
	exitThread = true 
	pixelCountingMutex.unlock()

	# Unblock by posting.
	pixelCountingSemaphore.post()

	# Wait until it exits.
	pixelCountingThread.wait_to_finish()


func _process(_delta):
	if scoreUpdate:
		scoreSignal.emit()
		scoreUpdate = false

## Passed a visual polygon which will be placed in the viewport to have the picture taken
func visualPolygonImageGenerator(p: Polygon2D) -> void:
	var ourPoly : Polygon2D = p.duplicate()
	sub_viewport.add_child(ourPoly)
	ourPoly.position = Vector2(150,150)
	ourPoly.rotation = 0
	
	await RenderingServer.frame_post_draw
	print("Attempting to make image")
	var myImage : Image = sub_viewport.get_texture().get_image()
	
	pixelCountingMutex.lock()
	imageToCount = myImage
	pixelCountingMutex.unlock()
	pixelCountingSemaphore.post()
	
	


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
