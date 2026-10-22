extends "res://scripts/enemies/enemy.gd"

enum Phase { APPROACH, WARNING, STRIKE, RECOVERY }
const REACH := 105.0
const HALF_ANGLE := 0.65
var phase: Phase = Phase.APPROACH
var phase_time: float = 0.0
var attack_direction := Vector2.LEFT

func _ready() -> void:
	max_health = 45
	body_radius = 18.0
	super._ready()

func _strike() -> void:
	var offset := target.global_position - global_position
	if offset.length() <= REACH and (offset.length() < 1.0 or attack_direction.dot(offset.normalized()) >= cos(HALF_ANGLE)):
		target.take_damage(18)

func _physics_process(delta: float) -> void:
	if not active or health <= 0 or not is_instance_valid(target):
		return
	hit_flash = maxf(0.0, hit_flash - delta)
	velocity = Vector2.ZERO
	if phase == Phase.APPROACH:
		if global_position.distance_to(target.global_position) > 95.0:
			velocity = global_position.direction_to(target.global_position) * 85.0
			visual_direction = velocity
		else:
			attack_direction = global_position.direction_to(target.global_position)
			if attack_direction == Vector2.ZERO:
				attack_direction = Vector2.LEFT
			visual_direction = attack_direction
			phase = Phase.WARNING
			phase_time = 0.75
	else:
		phase_time -= delta
		if phase_time <= 0.0:
			match phase:
				Phase.WARNING:
					phase = Phase.STRIKE
					phase_time = 0.18
					_strike()
				Phase.STRIKE:
					phase = Phase.RECOVERY
					phase_time = 1.1
				Phase.RECOVERY:
					phase = Phase.APPROACH
	move_and_slide()
	_update_visual("attack" if phase == Phase.STRIKE else "move" if velocity != Vector2.ZERO else "idle")
	queue_redraw()

func _draw() -> void:
	if phase in [Phase.WARNING, Phase.STRIKE]:
		var polygon := PackedVector2Array([Vector2.ZERO])
		for i in range(17):
			polygon.append(Vector2.from_angle(attack_direction.angle() - HALF_ANGLE + 2.0 * HALF_ANGLE * i / 16.0) * REACH)
		var color := Color("ffe095") if phase == Phase.WARNING else Color("ff806b")
		draw_colored_polygon(polygon, Color(color, 0.22))
		polygon.append(Vector2.ZERO)
		draw_polyline(polygon, color, 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(-25, -37), "GOLPE", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, color)
	if not has_sprite():
		var color := Color.WHITE if hit_flash > 0.0 else Color("a3b4c8") if phase == Phase.RECOVERY else Color("d9b678")
		draw_colored_polygon(PackedVector2Array([Vector2(0, -23), Vector2(20, -10), Vector2(17, 16), Vector2(0, 23), Vector2(-17, 16), Vector2(-20, -10)]), color)
		draw_line(Vector2(-12, -10), Vector2(12, -10), Color("8d4b61"), 7.0)
		draw_line(Vector2(-9, 0), Vector2(9, 0), Color("172537"), 4.0)
	draw_health_bar(40, 28)
