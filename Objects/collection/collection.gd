extends Node2D
@onready var text_screen_shot = $ColorRect/TextScreenShot

#TODO: Understand why the region has an odd offset
var screenshotRegion = Rect2(135,165,300,300)

@onready var sub_viewport = $SubViewportContainer/SubViewport

#TODO: Update colour definitions when a new texture is made
#region Asteroid Colors
var red : Color = Color(1, 0, 0, 1)
var green : Color = Color(0, 0.7569, 0.1255, 1)
var blue : Color = Color(0, 0.5804, 1, 1)
#endregion

func _on_collection_hit_box_body_entered(body):
	var toCopy: Polygon2D = body.visual
	var vis : Polygon2D = body.visual.duplicate()
	
	sub_viewport.add_child(vis)
	vis.position = Vector2(150,150)
	
	await RenderingServer.frame_post_draw
	print("Attempting to make image")
	var myImage : Image = sub_viewport.get_texture().get_image()
	
	#printAllPixels(myImage)

	var asteroidMakeUp: Dictionary = {"r":0,"g":0,"b":0}
	for i in range(0,300):
		for j in range(0,300):
			var testColor : Color = myImage.get_pixel(i,j)
			if (cmpColors(red,testColor)):
				asteroidMakeUp["r"] += 1
			if (cmpColors(green,testColor)):
				asteroidMakeUp["g"] += 1
			if (cmpColors(blue,testColor)):
				asteroidMakeUp["b"] += 1

	for key in asteroidMakeUp.keys():
		print(key, ": ", asteroidMakeUp[key])

	var screenshot = ImageTexture.create_from_image(myImage)
	vis.queue_free()
	text_screen_shot.texture = screenshot
	
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
