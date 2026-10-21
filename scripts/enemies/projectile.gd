extends CharacterBody2D

signal finished(projectile: Node)
var target: CharacterBody2D
var source: Node
var direction := Vector2.LEFT
var active: bool = true
var lifetime: float = 3.5

func _ready() -> void:
	collision_layer = 8
	collision_mask = 3 # Cenário e jogador; não atinge outros monstros.
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 6.0
	shape.shape = circle
	add_child(shape)

func cancel() -> void:
	if not active:
		return
	active = false
	hide()
	finished.emit(self)
	queue_free()

func _physics_process(delta: float) -> void:
	if not active:
		return
	if not is_instance_valid(target) or not target.active or target.health <= 0 or not is_instance_valid(source) or source.health <= 0:
		cancel()
		return
	lifetime -= delta
	if lifetime <= 0.0:
		cancel()
		return
	var collision := move_and_collide(direction * 230.0 * delta)
	if collision != null:
		if collision.get_collider() == target:
			target.take_damage(12)
		cancel()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 6.0, Color("b7eeff"))
	draw_circle(Vector2.ZERO, 6.0, Color("172537"), false, 2.0)
	draw_line(-direction * 7.0, -direction * 16.0, Color("b7eeff"), 3.0)
