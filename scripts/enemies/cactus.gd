extends "res://scripts/enemies/enemy.gd"

signal shot_requested(source: Node, origin: Vector2, direction: Vector2)
enum Phase { WARNING, RECOVERY }
const SPREAD := 0.28
var phase: Phase = Phase.WARNING
var phase_time: float = 0.95
var shot_direction := Vector2.LEFT

func _ready() -> void:
	max_health = 35
	super._ready()
	_lock_direction()

func _lock_direction() -> void:
	if is_instance_valid(target):
		shot_direction = global_position.direction_to(target.global_position)
		if shot_direction == Vector2.ZERO:
			shot_direction = Vector2.LEFT

func projectile_settings() -> Dictionary:
	return {"speed": 170.0, "damage": 8, "lifetime": 2.5, "thorn": true}

func _physics_process(delta: float) -> void:
	if not active or health <= 0 or not is_instance_valid(target):
		return
	hit_flash = maxf(0.0, hit_flash - delta)
	phase_time -= delta
	if phase_time <= 0.0:
		if phase == Phase.WARNING:
			for angle in [-SPREAD, 0.0, SPREAD]:
				var direction := shot_direction.rotated(angle)
				shot_requested.emit(self, global_position + direction * 24.0, direction)
			phase = Phase.RECOVERY
			phase_time = 1.6
		else:
			phase = Phase.WARNING
			phase_time = 0.95
			_lock_direction()
	_update_visual("attack" if phase == Phase.RECOVERY and phase_time > 1.3 else "idle")
	queue_redraw()

func _draw() -> void:
	if phase == Phase.WARNING:
		for angle in [-SPREAD, 0.0, SPREAD]:
			var direction := shot_direction.rotated(angle)
			draw_line(direction * 26.0, direction * 150.0, Color("ffe095"), 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(-34, -35), "ESPINHOS", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("ffe095"))
	if not has_sprite():
		draw_rect(Rect2(-12, -20, 24, 40), Color("77b94e"))
	draw_health_bar(40, 26)
