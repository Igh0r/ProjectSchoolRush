extends Node2D

signal cleared
const ENEMY_SCENES := {
	"dice": preload("res://scenes/enemies/dice.tscn"),
	"cloud": preload("res://scenes/enemies/cloud.tscn"),
	"centurion": preload("res://scenes/enemies/centurion.tscn"),
	"boss": preload("res://scenes/enemies/boss.tscn"),
}
const PROJECTILE = preload("res://scripts/enemies/projectile.gd")
const ENCOUNTERS := [
	{"kinds": ["dice", "dice"], "tip": "Dados perseguem e machucam por contato. Aproxime-se, golpeie e recue."},
	{"kinds": ["dice", "dice", "cloud"], "tip": "Nova ameaça: nuvem. A linha e o aviso DISPARO indicam a mira fixa. Saia da linha e aproxime-se entre os tiros."},
	{"kinds": ["dice", "dice", "cloud", "centurion"], "tip": "Nova ameaça: centurião. Saia do setor marcado GOLPE e ataque durante a recuperação. Cuidado também com a nuvem!"},
	{"kinds": ["boss"], "tip": "Napoleão espera no ginásio! A linha amarela avisa a direção da investida. Saia da linha e ataque durante a recuperação."},
]
const ENTRY := Vector2(100, 210)
const DOOR := Vector2(770, 210)
var enemies: Array[Node] = []
var projectiles: Array[Node] = []
var door_open: bool = false
var combat_active: bool = false
var boss_room: bool = false

func _ready() -> void:
	for wall in [Rect2(0, -12, 800, 24), Rect2(0, 408, 800, 24), Rect2(-12, 0, 24, 420), Rect2(788, 0, 24, 420)]:
		var body := StaticBody2D.new()
		body.position = wall.get_center()
		body.collision_layer = 2
		body.collision_mask = 0
		var collider := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = wall.size
		collider.shape = shape
		body.add_child(collider)
		add_child(body)

func clear_enemies() -> void:
	clear_projectiles()
	for enemy in enemies:
		enemy.active = false
		enemy.queue_free()
	enemies.clear()
	combat_active = false
	door_open = false
	boss_room = false
	queue_redraw()

func populate(index: int, player: CharacterBody2D) -> void:
	clear_enemies()
	boss_room = index == 3
	var points := [Vector2(520, 110), Vector2(650, 300), Vector2(470, 320), Vector2(680, 100)]
	var kinds: Array = ENCOUNTERS[index].kinds
	for i in range(kinds.size()):
		spawn_enemy(kinds[i], Vector2(600, 210) if boss_room else points[i], player)
	set_combat(true)
	queue_redraw()

func encounter_tip(index: int) -> String:
	return ENCOUNTERS[index].tip

func spawn_enemy(kind: String, point: Vector2, player: CharacterBody2D) -> Node:
	var enemy = ENEMY_SCENES[kind].instantiate()
	enemy.position = point
	enemy.target = player
	enemy.died.connect(_on_enemy_died)
	if enemy.has_signal("shot_requested"):
		enemy.shot_requested.connect(_spawn_projectile)
	enemies.append(enemy)
	add_child(enemy)
	enemy.active = combat_active
	return enemy

func _spawn_projectile(source: Node, origin: Vector2, direction: Vector2) -> void:
	if not combat_active or not is_instance_valid(source) or not enemies.has(source) or source.health <= 0:
		return
	var shot = PROJECTILE.new()
	shot.position = to_local(origin)
	shot.direction = direction.normalized()
	shot.target = source.target
	shot.source = source
	shot.finished.connect(func(projectile: Node): projectiles.erase(projectile))
	projectiles.append(shot)
	add_child(shot)

func clear_projectiles(source: Node = null) -> void:
	for shot in projectiles.duplicate():
		if source == null or shot.source == source:
			shot.cancel()

func set_combat(enabled: bool) -> void:
	combat_active = enabled
	if not enabled:
		clear_projectiles()
	for enemy in enemies:
		enemy.active = enabled

func strike(origin: Vector2, direction: Vector2, damage: int) -> void:
	if not combat_active:
		return
	for enemy in enemies.duplicate():
		var offset: Vector2 = enemy.global_position - origin
		if offset.length() <= 60.0 and (offset.length() < 1.0 or direction.dot(offset.normalized()) >= 0.5):
			enemy.take_damage(damage)

func _on_enemy_died(enemy: Node) -> void:
	clear_projectiles(enemy)
	enemies.erase(enemy)
	if enemies.is_empty():
		combat_active = false
		clear_projectiles()
		cleared.emit()

func open_door() -> void:
	door_open = true
	queue_redraw()

func can_exit(player_position: Vector2) -> bool:
	return door_open and player_position.distance_to(DOOR) <= 65.0

func _draw() -> void:
	draw_rect(Rect2(0, 0, 800, 420), Color("353047") if boss_room else Color("24354a"))
	for x in range(40, 800, 40):
		draw_line(Vector2(x, 12), Vector2(x, 408), Color("304257"), 1.0)
	for y in range(40, 420, 40):
		draw_line(Vector2(12, y), Vector2(788, y), Color("304257"), 1.0)
	draw_rect(Rect2(0, 0, 800, 420), Color("7087a3"), false, 24.0)
	if boss_room:
		draw_arc(Vector2(400, 210), 100.0, 0.0, TAU, 48, Color("817386"), 2.0)
		draw_line(Vector2(400, 12), Vector2(400, 408), Color("817386"), 2.0)
	else:
		draw_rect(Rect2(300, 15, 200, 28), Color("38675f"))
	draw_rect(Rect2(750, 170, 38, 80), Color("54d6a8") if door_open else Color("936577"))
	draw_line(Vector2(762, 210), Vector2(780, 210), Color.WHITE, 3.0)
