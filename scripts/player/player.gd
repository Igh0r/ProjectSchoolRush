extends CharacterBody2D

signal died
signal hurt
signal health_changed(value: int, maximum: int)
signal attacked(origin: Vector2, direction: Vector2, damage: int)

@export var speed: float = 230.0
@export var sprint_multiplier: float = 1.4
const BASE_MAX_HEALTH: int = 100
var max_health: int = BASE_MAX_HEALTH
var health: int = BASE_MAX_HEALTH
var damage: int = 10
var speed_bonus_percent: float = 0.0
var active: bool = false
var facing := Vector2.DOWN
var invulnerability: float = 0.0
var attack_cooldown: float = 0.0
var swing_time: float = 0.0

func reset_run() -> void:
	max_health = BASE_MAX_HEALTH
	health = max_health
	damage = 10
	speed_bonus_percent = 0.0
	facing = Vector2.DOWN
	invulnerability = 0.0
	attack_cooldown = 0.0
	swing_time = 0.0
	velocity = Vector2.ZERO
	health_changed.emit(health, max_health)
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
	velocity = direction * movement_speed() * (sprint_multiplier if Input.is_action_pressed("sprint") else 1.0)
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
	if not active or health <= 0 or invulnerability > 0.0 or amount <= 0:
		return
	health = maxi(0, health - amount)
	invulnerability = 0.7
	health_changed.emit(health, max_health)
	queue_redraw()
	hurt.emit()
	if health == 0:
		active = false
		died.emit()

func heal(amount: int) -> void:
	if amount <= 0 or health <= 0:
		return
	health = mini(max_health, health + amount)
	health_changed.emit(health, max_health)

func increase_max_health(amount: int) -> void:
	if amount <= 0 or health <= 0:
		return
	max_health += amount
	health_changed.emit(health, max_health)

func movement_speed() -> float:
	return speed * (1.0 + speed_bonus_percent / 100.0)

func apply_reward(reward: Dictionary) -> bool:
	if health <= 0 or reward.is_empty():
		return false
	match reward.get("type", ""):
		"damage":
			damage += int(reward.amount)
		"heal":
			var previous := health
			heal(int(reward.amount))
			return health > previous
		"max_health":
			increase_max_health(int(reward.amount))
			heal(int(reward.heal))
		"speed":
			var previous := speed_bonus_percent
			speed_bonus_percent = minf(float(reward.cap), speed_bonus_percent + float(reward.amount))
			return speed_bonus_percent > previous
		_:
			return false
	return true

func _draw() -> void:
	draw_circle(Vector2.ZERO, 15.0, Color.WHITE if invulnerability > 0.0 else Color("54d6a8"))
	draw_arc(Vector2.ZERO, 15.0, 0.0, TAU, 36, Color("ffffff"), 2.0)
	draw_circle(facing * 8.0, 3.0, Color("152632"))
	if swing_time > 0.0:
		draw_arc(Vector2.ZERO, 60.0, facing.angle() - PI / 3.0, facing.angle() + PI / 3.0, 16, Color("ffdb80"), 6.0)
	else:
		draw_line(facing * 18.0, facing * 34.0, Color("ffdb80"), 5.0)
