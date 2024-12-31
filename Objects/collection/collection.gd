extends Node2D
@onready var text_screen_shot = $ColorRect/TextScreenShot

#TODO: Understand why the region has an odd offset
var screenshotRegion = Rect2(135,165,300,300)

#TODO: Update colour definitions when a new texture is made
#region Asteroid Colors
var red : Color = Color(0.5529, 0, 0, 1)
var green : Color = Color(0, 0.4196, 0.0706, 1)
var blue : Color = Color(0, 0.3216, 0.5529, 1)
#endregion

func _on_collection_hit_box_body_entered(body):
	await RenderingServer.frame_post_draw
	print("Attempting to make image")
	var myImage : Image = get_viewport().get_texture().get_image().get_region(screenshotRegion)

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
	text_screen_shot.texture = screenshot

static func cmpColors(x: Color, y: Color) -> bool:
	if (x.a8 != y.a8):
		return false
	if (x.r8 != y.r8):
		return false
	if (x.g8 != y.g8):
		return false
	if (x.b8 != y.b8):
		return false
	return true
