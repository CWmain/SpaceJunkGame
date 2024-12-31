extends Node2D
@onready var text_screen_shot = $ColorRect/TextScreenShot

#TODO: Understand why the region has an odd offset
var screenshotRegion = Rect2(135,165,300,300)


func _on_collection_hit_box_body_entered(body):
	await RenderingServer.frame_post_draw
	print("Attempting to make image")
	var myImage : Image = get_viewport().get_texture().get_image().get_region(screenshotRegion)
	
	var screenshot = ImageTexture.create_from_image(myImage)
	text_screen_shot.texture = screenshot

	pass # Replace with function body.
