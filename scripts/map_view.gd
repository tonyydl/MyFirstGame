extends Node2D

var waypoints := PackedVector2Array([
	Vector2(40, 250), Vector2(240, 250), Vector2(240, 480),
	Vector2(480, 480), Vector2(480, 220), Vector2(720, 220),
	Vector2(720, 500), Vector2(850, 500)
])
const TOWER_POSITIONS := [Vector2(330, 350), Vector2(570, 350), Vector2(800, 370)]


func _ready() -> void:
	var curve := Curve2D.new()
	for point in waypoints:
		curve.add_point(point)
	$Route.curve = curve
	queue_redraw()


func _draw() -> void:
	draw_style_box(_ground_style(), Rect2(24, 116, 864, 560))
	for x in range(48, 880, 32):
		for y in range(140, 660, 32):
			draw_circle(Vector2(x, y), 1.0, Color(0.18, 0.28, 0.28))
	draw_polyline(waypoints, Color(0.1, 0.15, 0.17), 52.0, true)
	draw_polyline(waypoints, Color(0.32, 0.35, 0.29), 42.0, true)
	draw_polyline(waypoints, Color(0.53, 0.52, 0.36, 0.5), 2.0, true)
	for point in TOWER_POSITIONS:
		draw_circle(point, 31.0, Color(0.1, 0.19, 0.21))
		draw_arc(point, 31.0, 0, TAU, 48, Color(0.3, 0.55, 0.49), 2.0, true)
	draw_circle(waypoints[0], 23, Color(0.75, 0.38, 0.22))
	draw_colored_polygon(PackedVector2Array([
		Vector2(33, 239), Vector2(50, 250), Vector2(33, 261)
	]), Color(1, 0.84, 0.58))
	draw_rect(Rect2(827, 477, 46, 46), Color(0.24, 0.72, 0.59))
	draw_rect(Rect2(840, 488, 20, 24), Color(0.07, 0.2, 0.22))


func _ground_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.15, 0.17)
	style.set_corner_radius_all(16)
	return style
