extends Node2D

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const ARENA_SIZE: Vector2 = Vector2(800.0, 420.0)
const WALL_THICKNESS: float = 24.0

func _ready() -> void:
    _register_controls()
    _create_arena()
    var player := PLAYER_SCENE.instantiate() as CharacterBody2D
    player.position = ARENA_SIZE / 2.0
    add_child(player)
    _create_instructions()

func _register_controls() -> void:
    var bindings := {
        "move_left": [KEY_A, KEY_LEFT],
        "move_right": [KEY_D, KEY_RIGHT],
        "move_up": [KEY_W, KEY_UP],
        "move_down": [KEY_S, KEY_DOWN],
    }
    for action in bindings:
        if not InputMap.has_action(action):
            InputMap.add_action(action)
        for keycode in bindings[action]:
            var event := InputEventKey.new()
            event.physical_keycode = keycode
            InputMap.action_add_event(action, event)

func _create_arena() -> void:
    var floor := Polygon2D.new()
    floor.color = Color("223144")
    floor.polygon = PackedVector2Array([Vector2.ZERO, Vector2(800, 0), ARENA_SIZE, Vector2(0, 420)])
    add_child(floor)

    _create_wall(Vector2(400, 0), Vector2(824, WALL_THICKNESS))
    _create_wall(Vector2(400, 420), Vector2(824, WALL_THICKNESS))
    _create_wall(Vector2(0, 210), Vector2(WALL_THICKNESS, 444))
    _create_wall(Vector2(800, 210), Vector2(WALL_THICKNESS, 444))

func _create_wall(center: Vector2, dimensions: Vector2) -> void:
    var wall := StaticBody2D.new()
    wall.position = center
    wall.collision_layer = 2
    wall.collision_mask = 0
    var shape := CollisionShape2D.new()
    var rectangle := RectangleShape2D.new()
    rectangle.size = dimensions
    shape.shape = rectangle
    wall.add_child(shape)
    var visual := Polygon2D.new()
    visual.color = Color("7087a3")
    var half := dimensions / 2.0
    visual.polygon = PackedVector2Array([
        Vector2(-half.x, -half.y), Vector2(half.x, -half.y),
        Vector2(half.x, half.y), Vector2(-half.x, half.y)
    ])
    wall.add_child(visual)
    add_child(wall)

func _create_instructions() -> void:
    var ui := CanvasLayer.new()
    add_child(ui)
    var label := Label.new()
    label.position = Vector2(16, 12)
    label.text = "SCHOOL RUSH  |  Mover: WASD ou setas  |  Etapa 1: arena"
    ui.add_child(label)
