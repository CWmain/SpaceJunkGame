extends Area2D

@onready var cutter = $Cutter

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	self.position = get_global_mouse_position();
	if Input.is_action_just_pressed("PlacePoint"):
		print("Pressed")
		for entity in self.get_overlapping_bodies():
			var tc1 : PackedVector2Array = entity.get_child(1).polygon.duplicate()
			for i in range(tc1.size()):
				print("old: ", tc1[i], "  new: ", tc1[i]+entity.position)
				tc1[i] = tc1[i]+entity.position
				
			var c1 : PackedVector2Array = cutter.polygon.duplicate()
			for i in range(c1.size()):
				c1[i] = c1[i]+self.position
			
			var intersection = Geometry2D.clip_polygons(tc1, c1)

			for overlapping in intersection:
				var intersection_polygon = Polygon2D.new()
				print(overlapping)
				#intersection_polygon.transform = entity.transform
				intersection_polygon.color = Color.ROSY_BROWN
				intersection_polygon.set_polygon(overlapping)
				get_tree().get_root().add_child(intersection_polygon)
	





func _on_body_entered(body):
	print(body.position)
	print(body.rotation)
