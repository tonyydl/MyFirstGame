extends Node2D

signal shot

@export var attack_range: float = 155.0
@export var damage: int = 20
@export var cooldown: float = 0.65

var cooldown_left := 0.0
var beam_left := 0.0
var aim := Vector2.RIGHT
var beam_end := Vector2.ZERO


func _physics_process(delta: float) -> void:
	tick(delta)


func tick(delta: float) -> void:
	cooldown_left = maxf(0.0, cooldown_left - delta)
	beam_left = maxf(0.0, beam_left - delta)
	queue_redraw()
	if cooldown_left > 0.0:
		return
	# Target the enemy furthest along the route, within this tower's range.
	var target: Node2D = null
	var best_progress := -1.0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.resolved:
			continue
		if global_position.distance_squared_to(enemy.global_position) > attack_range * attack_range:
			continue
		if enemy.progress > best_progress:
			target = enemy
			best_progress = enemy.progress
	if target == null:
		return
	beam_end = to_local(target.global_position)
	aim = beam_end.normalized()
	beam_left = 0.12
	cooldown_left = cooldown
	target.take_damage(damage)
	shot.emit()


func _draw() -> void:
	draw_arc(Vector2.ZERO, attack_range, 0, TAU, 64, Color(0.31, 0.72, 0.63, 0.11), 1.0, true)
	draw_circle(Vector2(0, 5), 25, Color(0.02, 0.07, 0.09, 0.5))
	draw_circle(Vector2.ZERO, 24, Color(0.16, 0.29, 0.31))
	draw_arc(Vector2.ZERO, 24, 0, TAU, 36, Color(0.35, 0.69, 0.61), 2.0, true)
	draw_line(Vector2.ZERO, aim * 31, Color(0.49, 0.85, 0.75), 10, true)
	draw_circle(Vector2.ZERO, 13, Color(0.31, 0.77, 0.64))
	draw_circle(Vector2(-3, -4), 4, Color(0.72, 1, 0.84))
	if beam_left > 0.0:
		draw_line(aim * 27, beam_end, Color(0.58, 1, 0.7, beam_left / 0.12), 3, true)
