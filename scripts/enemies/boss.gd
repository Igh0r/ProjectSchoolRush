extends "res://scripts/enemies/enemy.gd"

enum Phase { WARNING, CHARGE, RECOVERY }
var phase: Phase = Phase.WARNING
var phase_time: float = 0.8
var charge_direction := Vector2.LEFT

func _ready() -> void:
	max_health = 150
	body_radius = 24.0
	super._ready()
	_lock_direction()

func _lock_direction() -> void:
	if is_instance_valid(target):
		charge_direction = global_position.direction_to(target.global_position)

func _physics_process(delta: float) -> void:
	if not active or health <= 0 or not is_instance_valid(target):
		return
	contact_cooldown = maxf(0.0, contact_cooldown - delta)
	hit_flash = maxf(0.0, hit_flash - delta)
	phase_time -= delta
	if phase_time <= 0.0:
		phase = ((phase + 1) % 3) as Phase
		phase_time = [0.8, 0.5, 1.2][phase]
		if phase == Phase.WARNING:
			_lock_direction()
	velocity = charge_direction * 420.0 if phase == Phase.CHARGE else Vector2.ZERO
	move_and_slide()
	if phase == Phase.CHARGE:
		if global_position.distance_to(target.global_position) < 40.0 and contact_cooldown <= 0.0:
			target.take_damage(20)
			contact_cooldown = 1.0
		if get_slide_collision_count() > 0:
			phase = Phase.RECOVERY
			phase_time = 1.2
	_update_visual("attack" if phase == Phase.CHARGE else "idle")
	queue_redraw()

func _draw() -> void:
	if phase == Phase.WARNING:
		draw_line(Vector2.ZERO, charge_direction * 210.0, Color("ffdd80"), 5.0)
		draw_arc(Vector2.ZERO, 30.0, 0.0, TAU, 32, Color("ffdd80"), 2.0)
	var color := Color("f3a95f") if phase != Phase.RECOVERY else Color("a3b4c8")
	if not has_sprite():
		draw_rect(Rect2(-24, -24, 48, 48), Color.WHITE if hit_flash > 0.0 else color)
		draw_colored_polygon(PackedVector2Array([Vector2(-32, -18), Vector2(0, -38), Vector2(32, -18)]), Color("111d2a"))
		draw_circle(Vector2(-7, -6), 3, Color.WHITE)
		draw_circle(Vector2(7, -6), 3, Color.WHITE)
	draw_health_bar(60, 32)
