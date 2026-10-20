extends PathFollow2D

signal escaped
signal defeated

@export var speed: float = 90.0
var max_health := 60
var health := 60
var resolved := false


func setup(initial_health: int, movement_speed: float) -> void:
	max_health = maxi(1, initial_health)
	health = max_health
	speed = maxf(0.0, movement_speed)


func _ready() -> void:
	loop = false
	rotates = false
	add_to_group("enemies")
	queue_redraw()


func _physics_process(delta: float) -> void:
	advance(delta)


func advance(delta: float) -> void:
	if resolved:
		return
	progress += speed * maxf(delta, 0.0)
	if progress_ratio >= 1.0:
		resolved = true
		remove_from_group("enemies")
		escaped.emit()
		queue_free()


func take_damage(amount: int) -> void:
	if resolved or amount <= 0:
		return
	health = maxi(0, health - amount)
	queue_redraw()
	if health == 0:
		resolved = true
		remove_from_group("enemies")
		defeated.emit()
		queue_free()


func _draw() -> void:
	draw_circle(Vector2(0, 4), 16, Color(0, 0, 0, 0.25))
	draw_circle(Vector2.ZERO, 14, Color(0.92, 0.42, 0.29))
	draw_circle(Vector2(-4, -3), 3, Color(1, 0.88, 0.61))
	draw_circle(Vector2(5, -3), 3, Color(1, 0.88, 0.61))
	draw_rect(Rect2(-17, -25, 34, 5), Color(0.06, 0.1, 0.12))
	draw_rect(Rect2(-17, -25, 34.0 * health / max_health, 5), Color(0.49, 0.91, 0.52))
