extends Node2D
@onready var text_screen_shot = $ColorRect/TextScreenShot

#TODO: Understand why the region has an odd offset
var screenshotRegion = Rect2(135,165,300,300)


func _on_collection_hit_box_body_entered(body):
	await RenderingServer.frame_post_draw
	print("Attempting to make image")
	var myImage : Image = get_viewport().get_texture().get_image().get_region(screenshotRegion)
	var dict : Dictionary = {}
	
	for i in range(0,300):
		for j in range(0,300):
			if dict.has(myImage.get_pixel(i,j)):
				dict[myImage.get_pixel(i,j)] += 1
			else:
				dict[myImage.get_pixel(i,j)] = 1
	for key in dict.keys():
		if dict[key] > 200:
			print(key, ": ", dict[key])

	var screenshot = ImageTexture.create_from_image(myImage)
	text_screen_shot.texture = screenshot

	pass # Replace with function body.
