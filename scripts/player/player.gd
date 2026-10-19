extends CharacterBody2D

signal died
signal health_changed(value: int)
signal attacked(origin: Vector2, direction: Vector2, damage: int)

@export var speed: float = 230.0
@export var sprint_multiplier: float = 1.4
var health: int = 100
var damage: int = 10
var active: bool = false
var facing := Vector2.DOWN
var invulnerability: float = 0.0
var attack_cooldown: float = 0.0
var swing_time: float = 0.0

func reset_run() -> void:
	health = 100
	damage = 10
	facing = Vector2.DOWN
	invulnerability = 0.0
	attack_cooldown = 0.0
	swing_time = 0.0
	velocity = Vector2.ZERO
	health_changed.emit(health)
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not active or health <= 0:
		return
	invulnerability = maxf(0.0, invulnerability - delta)
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	swing_time = maxf(0.0, swing_time - delta)
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		facing = direction
	velocity = direction * speed * (sprint_multiplier if Input.is_action_pressed("sprint") else 1.0)
	move_and_slide()
	if Input.is_action_pressed("attack"):
		attack()
	queue_redraw()

func attack() -> void:
	if not active or health <= 0 or attack_cooldown > 0.0:
		return
	attack_cooldown = 0.4
	swing_time = 0.14
	attacked.emit(global_position, facing, damage)
	queue_redraw()

func take_damage(amount: int) -> void:
	if not active or health <= 0 or invulnerability > 0.0:
		return
	health = maxi(0, health - amount)
	invulnerability = 0.7
	health_changed.emit(health)
	queue_redraw()
	if health == 0:
		active = false
		died.emit()

func heal(amount: int) -> void:
	health = mini(100, health + amount)
	health_changed.emit(health)

func _draw() -> void:
	draw_circle(Vector2.ZERO, 15.0, Color.WHITE if invulnerability > 0.0 else Color("54d6a8"))
	draw_arc(Vector2.ZERO, 15.0, 0.0, TAU, 36, Color("ffffff"), 2.0)
	draw_circle(facing * 8.0, 3.0, Color("152632"))
	if swing_time > 0.0:
		draw_arc(Vector2.ZERO, 60.0, facing.angle() - PI / 3.0, facing.angle() + PI / 3.0, 16, Color("ffdb80"), 6.0)
	else:
		draw_line(facing * 18.0, facing * 34.0, Color("ffdb80"), 5.0)
