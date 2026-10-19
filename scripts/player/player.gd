extends CharacterBody2D

@export var speed: float = 230.0

func _ready() -> void:
	queue_redraw()

func _physics_process(_delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 15.0, Color("54d6a8"))
	draw_arc(Vector2.ZERO, 15.0, 0.0, TAU, 36, Color("ffffff"), 2.0)
	draw_circle(Vector2(5, -4), 3.0, Color("152632"))
