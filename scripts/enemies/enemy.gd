extends CharacterBody2D

signal died(enemy: Node)
@export var max_health: int = 30
@export var body_radius: float = 16.0
@export var face_target: bool = false
var visual_direction := Vector2.RIGHT
var target: CharacterBody2D
var active: bool = false
var health: int = 30
var contact_cooldown: float = 0.0
var hit_flash: float = 0.0

func _ready() -> void:
	health = max_health
	collision_layer = 4
	collision_mask = 2
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	if not has_node("CollisionShape2D"):
		var shape := CollisionShape2D.new()
		shape.name = "CollisionShape2D"
		var circle := CircleShape2D.new()
		circle.radius = body_radius
		shape.shape = circle
		add_child(shape)
	_update_visual("idle")

func _update_visual(animation_name: String) -> void:
	var sprite := get_node_or_null("Visual/AnimatedSprite2D") as AnimatedSprite2D
	if sprite == null:
		return
	var frames := sprite.sprite_frames
	if frames == null:
		sprite.visible = false
		return
	var chosen := animation_name if frames.has_animation(animation_name) and frames.get_frame_count(animation_name) > 0 else "idle"
	sprite.visible = frames.has_animation(chosen) and frames.get_frame_count(chosen) > 0
	if sprite.visible:
		sprite.play(chosen)
		sprite.flip_h = face_target and visual_direction.x < 0.0
		sprite.modulate = Color(2, 2, 2) if hit_flash > 0.0 else Color.WHITE

func has_sprite() -> bool:
	var sprite := get_node_or_null("Visual/AnimatedSprite2D") as AnimatedSprite2D
	return sprite != null and sprite.visible

func draw_health_bar(width: float, y: float) -> void:
	draw_rect(Rect2(-width / 2.0, y, width, 4), Color("172537"))
	draw_rect(Rect2(-width / 2.0, y, width * float(health) / max_health, 4), Color("54d6a8"))

func _physics_process(delta: float) -> void:
	if not active or health <= 0 or not is_instance_valid(target):
		return
	contact_cooldown = maxf(0.0, contact_cooldown - delta)
	hit_flash = maxf(0.0, hit_flash - delta)
	velocity = global_position.direction_to(target.global_position) * 100.0
	visual_direction = velocity
	move_and_slide()
	if global_position.distance_to(target.global_position) < 32.0 and contact_cooldown <= 0.0:
		target.take_damage(10)
		contact_cooldown = 1.0
	_update_visual("attack" if contact_cooldown > 0.8 else "move")
	queue_redraw()

func take_damage(amount: int) -> void:
	if health <= 0 or amount <= 0:
		return
	health = maxi(0, health - amount)
	hit_flash = 0.12
	_update_visual("hurt")
	queue_redraw()
	if health == 0:
		active = false
		died.emit(self)
		queue_free()

func _draw() -> void:
	if not has_sprite():
		draw_rect(Rect2(-16, -16, 32, 32), Color.WHITE if hit_flash > 0.0 else Color("df7c8b"))
		for dot in [Vector2(-7, -7), Vector2.ZERO, Vector2(7, 7)]:
			draw_circle(dot, 3.0, Color("172537"))
	draw_health_bar(32, 23)
