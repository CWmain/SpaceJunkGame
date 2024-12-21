extends Node2D

var cut_line: Line2D

@onready var to_cut : Polygon2D = $ToCut
@onready var cutter : Polygon2D = $Cutter

	
func _ready():
	var intersection = Geometry2D.clip_polygons(to_cut.polygon, cutter.polygon)

	for overlapping in intersection:
		var intersection_polygon = Polygon2D.new()
		print(overlapping)
		intersection_polygon.transform = to_cut.transform
		intersection_polygon.color = Color.ROSY_BROWN
		intersection_polygon.set_polygon(overlapping)
		self.add_child(intersection_polygon)
	
func place_point():
	var mouse_pos = get_viewport().get_mouse_position()
	var image = get_viewport().get_texture().get_image()
	if not (
			0 <= mouse_pos.x and mouse_pos.x < image.get_width() and\
			0 <= mouse_pos.y and mouse_pos.y < image.get_height()
			):
		return

	if Input.is_action_just_pressed("PlacePoint"):
		print('drew')
		var dist_to_last_point = 0

		cut_line.add_point(mouse_pos)
		complete_shape()
		adjust_for_first_point()


		
func adjust_for_first_point():
	var extra = Vector2(3, 3)
	if cut_line.get_point_count() == 1:
		cut_line.add_point(cut_line.get_point_position(0) + extra)
	elif cut_line.get_point_position(0) + extra == cut_line.get_point_position(1) :
		cut_line.remove_point(1)
		
func complete_shape():
	var dist = cut_line.points[0].distance_to(cut_line.points[-1])
	prints("dist", dist)

	if len(cut_line.points) > 1:
		print("shape complete!")
		print(cut_line.points)
		var intersection_calc = Geometry2D.clip_polygons.call(
				to_cut.polygon, cut_line.points
		)
		prints("intersection calc", intersection_calc)
		for overlapping_polygon in intersection_calc:
			var intersection_polygon = Polygon2D.new()
			prints("overlapping_polygon", overlapping_polygon)
			self.add_child(intersection_polygon)
			intersection_polygon.color = Color.GREEN
			intersection_polygon.set_polygon(overlapping_polygon)
			print(intersection_polygon.polygon)
		self.remove_child(to_cut)
