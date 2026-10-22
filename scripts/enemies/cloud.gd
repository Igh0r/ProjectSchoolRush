extends "res://scripts/enemies/enemy.gd"

signal shot_requested(source: Node, origin: Vector2, direction: Vector2)
enum Phase { APPROACH, WARNING, RECOVERY }
var phase: Phase = Phase.APPROACH
var phase_time: float = 0.0
var shot_direction := Vector2.LEFT

func _ready() -> void:
	max_health = 25
	super._ready()

func _physics_process(delta: float) -> void:
	if not active or health <= 0 or not is_instance_valid(target):
		return
	hit_flash = maxf(0.0, hit_flash - delta)
	velocity = Vector2.ZERO
	if phase == Phase.APPROACH:
		var distance := global_position.distance_to(target.global_position)
		if distance > 300.0:
			velocity = global_position.direction_to(target.global_position) * 70.0
		else:
			shot_direction = global_position.direction_to(target.global_position)
			if shot_direction == Vector2.ZERO:
				shot_direction = Vector2.LEFT
			phase = Phase.WARNING
			phase_time = 0.8
	else:
		phase_time -= delta
		if phase_time <= 0.0:
			if phase == Phase.WARNING:
				shot_requested.emit(self, global_position + shot_direction * 24.0, shot_direction)
				phase = Phase.RECOVERY
				phase_time = 1.2
			else:
				phase = Phase.APPROACH
	move_and_slide()
	_update_visual("attack" if phase == Phase.RECOVERY and phase_time > 1.0 else "move" if velocity != Vector2.ZERO else "idle")
	queue_redraw()

func _draw() -> void:
	if phase == Phase.WARNING:
		draw_line(shot_direction * 25.0, shot_direction * 180.0, Color("ffe095"), 3.0)
		draw_circle(shot_direction * 180.0, 5.0, Color("ffe095"), false, 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(-32, -35), "DISPARO", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("ffe095"))
	if not has_sprite():
		var color := Color.WHITE if hit_flash > 0.0 else Color("a7d8f4")
		draw_circle(Vector2(-12, 1), 13, color)
		draw_circle(Vector2(0, -8), 17, color)
		draw_circle(Vector2(14, 2), 12, color)
		draw_circle(Vector2(-6, -4), 3, Color("172537"))
		draw_circle(Vector2(7, -4), 3, Color("172537"))
	draw_health_bar(40, 25)
