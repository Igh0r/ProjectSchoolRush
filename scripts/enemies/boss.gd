extends "res://scripts/enemies/enemy.gd"

enum Phase { WARNING, CHARGE, RECOVERY, APPROACH, SWEEP_WARNING, SWEEP }
const SWEEP_REACH := 125.0
const SWEEP_HALF_ANGLE := 0.9
var phase: Phase = Phase.WARNING
var phase_time: float = 0.8
var charge_direction := Vector2.LEFT
var next_sweep := true

func _ready() -> void:
	max_health = 150
	body_radius = 24.0
	super._ready()
	_lock_direction()

func _lock_direction() -> void:
	if is_instance_valid(target):
		charge_direction = global_position.direction_to(target.global_position)
		if charge_direction == Vector2.ZERO:
			charge_direction = Vector2.LEFT
		visual_direction = charge_direction

func _recover() -> void:
	finish_special_attack()
	phase = Phase.RECOVERY
	phase_time = 1.2
	velocity = Vector2.ZERO

func _sweep() -> void:
	var offset := target.global_position - global_position
	if offset.length() <= SWEEP_REACH and (offset.length() < 1.0 or charge_direction.dot(offset.normalized()) >= cos(SWEEP_HALF_ANGLE)):
		target.take_damage(20)

func _physics_process(delta: float) -> void:
	if not active or health <= 0 or not is_instance_valid(target):
		return
	contact_cooldown = maxf(0.0, contact_cooldown - delta)
	hit_flash = maxf(0.0, hit_flash - delta)
	velocity = Vector2.ZERO
	if phase in [Phase.WARNING, Phase.SWEEP_WARNING] and not request_special_attack():
		return
	phase_time -= delta
	match phase:
		Phase.WARNING:
			if phase_time <= 0.0:
				phase = Phase.CHARGE
				phase_time = 0.5
				next_sweep = true
		Phase.CHARGE:
			if phase_time <= 0.0:
				_recover()
		Phase.RECOVERY:
			if phase_time <= 0.0:
				if next_sweep:
					phase = Phase.APPROACH
					phase_time = 1.6
				elif request_special_attack():
					phase = Phase.WARNING
					phase_time = 0.8
					_lock_direction()
		Phase.APPROACH:
			if global_position.distance_to(target.global_position) <= 115.0 and request_special_attack():
				phase = Phase.SWEEP_WARNING
				phase_time = 0.9
				_lock_direction()
			elif phase_time <= 0.0 and request_special_attack():
				# Se o jogador se afastou, uma investida anunciada fecha a distância.
				phase = Phase.WARNING
				phase_time = 0.8
				_lock_direction()
			else:
				velocity = steered_velocity(target.global_position, 100.0)
				visual_direction = velocity
		Phase.SWEEP_WARNING:
			if phase_time <= 0.0:
				phase = Phase.SWEEP
				phase_time = 0.2
				next_sweep = false
				_sweep()
		Phase.SWEEP:
			if phase_time <= 0.0:
				_recover()
	if phase == Phase.CHARGE:
		velocity = charge_direction * 420.0
	move_and_slide()
	if phase == Phase.CHARGE:
		if global_position.distance_to(target.global_position) < 40.0 and contact_cooldown <= 0.0:
			target.take_damage(20)
			contact_cooldown = 1.0
		if get_slide_collision_count() > 0:
			_recover()
	_update_visual("attack" if phase in [Phase.CHARGE, Phase.SWEEP] else "move" if velocity != Vector2.ZERO else "idle")
	queue_redraw()

func _draw() -> void:
	if phase == Phase.WARNING:
		draw_line(Vector2.ZERO, charge_direction * 210.0, Color("ffdd80"), 5.0)
		draw_arc(Vector2.ZERO, 30.0, 0.0, TAU, 32, Color("ffdd80"), 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(-40, -49), "INVESTIDA", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("ffdd80"))
	if phase in [Phase.SWEEP_WARNING, Phase.SWEEP]:
		var polygon := PackedVector2Array([Vector2.ZERO])
		for i in range(25):
			polygon.append(Vector2.from_angle(charge_direction.angle() - SWEEP_HALF_ANGLE + 2.0 * SWEEP_HALF_ANGLE * i / 24.0) * SWEEP_REACH)
		var warning_color := Color("ffe095") if phase == Phase.SWEEP_WARNING else Color("ff806b")
		draw_colored_polygon(polygon, Color(warning_color, 0.22))
		polygon.append(Vector2.ZERO)
		draw_polyline(polygon, warning_color, 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(-29, -49), "VARREDURA", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, warning_color)
	if phase == Phase.RECOVERY:
		draw_recovery()
	var color := Color("f3a95f") if phase != Phase.RECOVERY else Color("a3b4c8")
	if not has_sprite():
		draw_rect(Rect2(-24, -24, 48, 48), Color.WHITE if hit_flash > 0.0 else color)
		draw_colored_polygon(PackedVector2Array([Vector2(-32, -18), Vector2(0, -38), Vector2(32, -18)]), Color("111d2a"))
		draw_circle(Vector2(-7, -6), 3, Color.WHITE)
		draw_circle(Vector2(7, -6), 3, Color.WHITE)
	draw_health_bar(60, 32)
