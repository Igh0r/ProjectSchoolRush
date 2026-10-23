extends "res://scripts/enemies/enemy.gd"

signal mixture_requested(source: Node, point: Vector2)
enum Phase { APPROACH, WARNING, RECOVERY }
var phase: Phase = Phase.APPROACH
var phase_time: float = 0.0
var aim_point := Vector2.ZERO

func _ready() -> void:
	max_health = 35
	super._ready()

func _physics_process(delta: float) -> void:
	if not active or health <= 0 or not is_instance_valid(target):
		return
	hit_flash = maxf(0.0, hit_flash - delta)
	velocity = Vector2.ZERO
	if phase == Phase.APPROACH:
		if global_position.distance_to(target.global_position) > 300.0:
			velocity = steered_velocity(target.global_position, 55.0)
			visual_direction = velocity
		else:
			aim_point = target.global_position
			visual_direction = global_position.direction_to(aim_point)
			phase = Phase.WARNING
			phase_time = 1.0
			mixture_requested.emit(self, aim_point)
	else:
		phase_time -= delta
		if phase_time <= 0.0:
			if phase == Phase.WARNING:
				phase = Phase.RECOVERY
				phase_time = 2.2
			else:
				phase = Phase.APPROACH
		elif phase == Phase.RECOVERY and phase_time < 1.2:
			velocity = reposition_velocity(40.0, 150.0, 230.0)
			visual_direction = velocity
	move_and_slide()
	_update_visual("attack" if phase == Phase.WARNING else "move" if velocity != Vector2.ZERO else "idle")
	queue_redraw()

func _draw() -> void:
	if phase == Phase.WARNING:
		draw_string(ThemeDB.fallback_font, Vector2(-31, -35), "MISTURA", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("ffe095"))
	if not has_sprite():
		draw_rect(Rect2(-14, -20, 28, 40), Color("d6e4dc"))
	draw_health_bar(40, 26)
