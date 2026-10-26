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
var active: bool = false:
	set(value):
		active = value
		if not active:
			attack_visual_active = false
			_update_visual()
			queue_redraw()
var facing := Vector2.DOWN
var invulnerability: float = 0.0
var attack_cooldown: float = 0.0
var swing_time: float = 0.0
var attack_direction := Vector2.DOWN
var attack_visual_active: bool = false
@onready var visual: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

func _ready() -> void:
	if visual != null:
		visual.animation_finished.connect(_on_visual_finished)
	_update_visual()

func _on_visual_finished() -> void:
	attack_visual_active = false
	_update_visual()

func _visual_direction(direction: Vector2) -> String:
	# Quatro vistas disponíveis; diagonais mantêm o cone físico e usam a vista vertical no empate.
	if absf(direction.x) > absf(direction.y):
		return "right" if direction.x > 0 else "left"
	return "down" if direction.y >= 0 else "up"

func _update_visual() -> void:
	if visual == null:
		return
	visual.modulate = Color(0.6, 0.6, 0.6) if health <= 0 else (Color(1.4, 0.7, 0.7) if invulnerability > 0.58 else Color.WHITE)
	if health <= 0:
		visual.pause()
		return
	if active and attack_visual_active:
		return
	var animation_name := "walk_" + _visual_direction(facing)
	if active and velocity.length_squared() > 1.0:
		visual.speed_scale = velocity.length() / speed
		visual.play(animation_name)
	else:
		visual.animation = animation_name
		visual.pause()
		visual.set_frame_and_progress(0, 0.0)
		visual.speed_scale = 1.0

func reset_run() -> void:
	max_health = BASE_MAX_HEALTH
	health = max_health
	damage = 10
	speed_bonus_percent = 0.0
	facing = Vector2.DOWN
	invulnerability = 0.0
	attack_cooldown = 0.0
	swing_time = 0.0
	attack_direction = Vector2.DOWN
	attack_visual_active = false
	velocity = Vector2.ZERO
	health_changed.emit(health, max_health)
	_update_visual()
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not active or health <= 0:
		_update_visual()
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
	_update_visual()
	queue_redraw()

func attack() -> void:
	if not active or health <= 0 or attack_cooldown > 0.0:
		return
	attack_cooldown = 0.4
	swing_time = 0.14
	attack_direction = facing
	if visual != null:
		attack_visual_active = true
		visual.speed_scale = 1.25 # 12 fps da fonte → 15 fps; recuperação visual de 0,2 s.
		visual.play("attack_" + _visual_direction(attack_direction))
		visual.set_frame_and_progress(3, 0.0) # Quadro de impacto acompanha o dano imediato.
	attacked.emit(global_position, facing, damage)
	queue_redraw()

func take_damage(amount: int) -> void:
	if not active or health <= 0 or invulnerability > 0.0 or amount <= 0:
		return
	health = maxi(0, health - amount)
	invulnerability = 0.7
	_update_visual()
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
	draw_circle(Vector2.ZERO, 15.0, Color(0.03, 0.06, 0.1, 0.3))
	if invulnerability > 0 and health > 0:
		draw_arc(Vector2.ZERO, 17.0, 0, TAU, 32, Color.WHITE, 1.5)
	if active and swing_time > 0.0:
		draw_arc(Vector2.ZERO, 60.0, attack_direction.angle() - PI / 3.0, attack_direction.angle() + PI / 3.0, 24, Color("ffdb80"), 2.0)
	elif health > 0:
		# Indica a direção exata, inclusive nas diagonais que não têm sprites próprios.
		draw_line(facing * 21.0, facing * 28.0, Color("ffdb80"), 2.0)
