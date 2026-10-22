extends Node2D

signal finished(hazard: Node)
const RADIUS := 42.0
var source: Node
var target: CharacterBody2D
var active: bool = true
var warning: bool = true
var phase_time: float = 1.0
var has_hit: bool = false

func cancel() -> void:
	if not active:
		return
	active = false
	hide()
	finished.emit(self)
	queue_free()

func _physics_process(delta: float) -> void:
	if not active:
		return
	if not is_instance_valid(source) or source.health <= 0 or not is_instance_valid(target) or not target.active or target.health <= 0:
		cancel()
		return
	phase_time -= delta
	if phase_time <= 0.0:
		if warning:
			warning = false
			phase_time = 1.2
		else:
			cancel()
			return
	if not warning and not has_hit and target.invulnerability <= 0.0 and target.global_position.distance_to(global_position) <= RADIUS:
		has_hit = true
		target.take_damage(10)
	queue_redraw()

func _draw() -> void:
	var color := Color("ffe095") if warning else Color("a8ef75")
	draw_circle(Vector2.ZERO, RADIUS, Color(color, 0.15 if warning else 0.35))
	draw_circle(Vector2.ZERO, RADIUS, Color("172537"), false, 5.0)
	draw_arc(Vector2.ZERO, RADIUS, 0, TAU, 48, color, 2.0)
	if warning:
		draw_line(Vector2(-8, 0), Vector2(8, 0), color, 2.0)
		draw_line(Vector2(0, -8), Vector2(0, 8), color, 2.0)
	else:
		for point in [Vector2(-15, 8), Vector2(12, -9), Vector2(10, 20)]:
			draw_circle(point, 6.0, color)
