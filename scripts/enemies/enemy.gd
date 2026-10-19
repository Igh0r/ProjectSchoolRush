extends CharacterBody2D

signal died(enemy: Node)
var target: CharacterBody2D
var active: bool = false
var health: int = 30
var contact_cooldown: float = 0.0
var hit_flash: float = 0.0

func _ready() -> void:
	collision_layer = 4
	collision_mask = 2
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 16.0
	shape.shape = circle
	add_child(shape)

func _physics_process(delta: float) -> void:
	if not active or health <= 0 or not is_instance_valid(target):
		return
	contact_cooldown = maxf(0.0, contact_cooldown - delta)
	hit_flash = maxf(0.0, hit_flash - delta)
	velocity = global_position.direction_to(target.global_position) * 100.0
	move_and_slide()
	if global_position.distance_to(target.global_position) < 32.0 and contact_cooldown <= 0.0:
		target.take_damage(10)
		contact_cooldown = 1.0
	queue_redraw()

func take_damage(amount: int) -> void:
	if health <= 0:
		return
	health = maxi(0, health - amount)
	hit_flash = 0.12
	queue_redraw()
	if health == 0:
		active = false
		died.emit(self)
		queue_free()

func _draw() -> void:
	draw_rect(Rect2(-16, -16, 32, 32), Color.WHITE if hit_flash > 0.0 else Color("df7c8b"))
	for dot in [Vector2(-7, -7), Vector2.ZERO, Vector2(7, 7)]:
		draw_circle(dot, 3.0, Color("172537"))
	draw_rect(Rect2(-16, 23, 32, 4), Color("172537"))
	draw_rect(Rect2(-16, 23, 32 * float(health) / 30.0, 4), Color("54d6a8"))
