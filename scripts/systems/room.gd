extends Node2D

signal cleared
const ENEMY_SCENES := {
	"dice": preload("res://scenes/enemies/dice.tscn"),
	"cloud": preload("res://scenes/enemies/cloud.tscn"),
	"centurion": preload("res://scenes/enemies/centurion.tscn"),
	"boss": preload("res://scenes/enemies/boss.tscn"),
	"cactus": preload("res://scenes/enemies/cactus.tscn"),
	"scientist": preload("res://scenes/enemies/scientist.tscn"),
}
const PROJECTILE = preload("res://scripts/enemies/projectile.gd")
const MIXTURE = preload("res://scripts/enemies/mixture.gd")
const ENCOUNTERS := [
	{"kinds": ["dice", "dice"], "tip": "Dados perseguem e machucam por contato. Aproxime-se, golpeie e recue."},
	{"kinds": ["dice", "dice", "cloud"], "tip": "Nova ameaça: nuvem. A linha e o aviso DISPARO indicam a mira fixa. Saia da linha e aproxime-se entre os tiros."},
	{"kinds": ["dice", "dice", "cloud", "centurion"], "tip": "Nova ameaça: centurião. Saia do setor marcado GOLPE e ataque durante a recuperação. Cuidado também com a nuvem!"},
	{"kinds": ["boss"], "tip": "Napoleão espera no ginásio! A linha amarela avisa a direção da investida. Saia da linha e ataque durante a recuperação."},
]
const SCIENCE_ENCOUNTERS := [
	{"kinds": ["dice", "dice"], "tip": "A expedição começa na sala de aula. Dados perseguem e machucam por contato."},
	{"kinds": ["dice", "cactus", "cloud"], "tip": "No pátio, o cacto fica parado e anuncia três ESPINHOS. Saia das linhas; também há uma nuvem."},
	{"kinds": ["dice", "centurion", "scientist", "cloud"], "tip": "No laboratório, o cientista marca uma MISTURA no chão. Saia do círculo antes de ficar verde; evite também o setor do centurião."},
	ENCOUNTERS[3],
]
const BACKGROUNDS := [
	preload("res://assets/rooms/classroom.png"), preload("res://assets/rooms/courtyard.png"),
	preload("res://assets/rooms/laboratory.png"), preload("res://assets/rooms/gym.png"),
]
const FLOOR_REGIONS := [Rect2(100, 220, 1280, 320), Rect2(128, 228, 1240, 260), Rect2(100, 232, 1280, 344), Rect2(150, 208, 1180, 340)]
const THEME_NAMES := ["SALA DE AULA", "PÁTIO", "LABORATÓRIO", "GINÁSIO"]
const ENTRY := Vector2(100, 210)
const DOOR := Vector2(770, 210)
var enemies: Array[Node] = []
var projectiles: Array[Node] = []
var mixtures: Array[Node] = []
var route_index: int = 0
var theme_index: int = 0
var door_open: bool = false
var combat_active: bool = false
var boss_room: bool = false

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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
	clear_mixtures()
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
	set_room_theme(index)
	boss_room = index == 3
	var points := [Vector2(520, 110), Vector2(650, 300), Vector2(470, 320), Vector2(680, 100)]
	var kinds: Array = encounter(index).kinds
	for i in range(kinds.size()):
		spawn_enemy(kinds[i], Vector2(600, 210) if boss_room else points[i], player)
	set_combat(true)
	queue_redraw()

func encounter_tip(index: int) -> String:
	return encounter(index).tip

func encounter(index: int) -> Dictionary:
	return SCIENCE_ENCOUNTERS[index] if route_index == 1 else ENCOUNTERS[index]

func set_room_theme(index: int) -> void:
	theme_index = index if route_index == 1 or index == 3 else 0
	queue_redraw()

func route_name() -> String:
	return "Expedição científica" if route_index == 1 else "Rota clássica"

func spawn_enemy(kind: String, point: Vector2, player: CharacterBody2D) -> Node:
	var enemy = ENEMY_SCENES[kind].instantiate()
	enemy.position = point
	enemy.target = player
	enemy.died.connect(_on_enemy_died)
	if enemy.has_signal("shot_requested"):
		enemy.shot_requested.connect(_spawn_projectile)
	if enemy.has_signal("mixture_requested"):
		enemy.mixture_requested.connect(_spawn_mixture)
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
	var settings: Dictionary = source.projectile_settings()
	shot.speed = settings.get("speed", shot.speed)
	shot.damage = settings.get("damage", shot.damage)
	shot.lifetime = settings.get("lifetime", shot.lifetime)
	shot.thorn = settings.get("thorn", false)
	shot.finished.connect(func(projectile: Node): projectiles.erase(projectile))
	projectiles.append(shot)
	add_child(shot)

func _spawn_mixture(source: Node, point: Vector2) -> void:
	if not combat_active or not enemies.has(source) or source.health <= 0:
		return
	var mixture = MIXTURE.new()
	mixture.source = source
	mixture.target = source.target
	mixture.position = to_local(point).clamp(Vector2(54, 54), Vector2(746, 366))
	mixture.finished.connect(func(hazard: Node): mixtures.erase(hazard))
	mixtures.append(mixture)
	add_child(mixture)

func clear_mixtures(source: Node = null) -> void:
	for mixture in mixtures.duplicate():
		if source == null or mixture.source == source:
			mixture.cancel()

func clear_projectiles(source: Node = null) -> void:
	for shot in projectiles.duplicate():
		if source == null or shot.source == source:
			shot.cancel()

func set_combat(enabled: bool) -> void:
	combat_active = enabled
	if not enabled:
		clear_projectiles()
		clear_mixtures()
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
	clear_mixtures(enemy)
	enemies.erase(enemy)
	if enemies.is_empty():
		combat_active = false
		clear_projectiles()
		clear_mixtures()
		cleared.emit()

func open_door() -> void:
	door_open = true
	queue_redraw()

func can_exit(player_position: Vector2) -> bool:
	return door_open and player_position.distance_to(DOOR) <= 65.0

func _draw() -> void:
	draw_texture_rect_region(BACKGROUNDS[theme_index], Rect2(0, 0, 800, 420), FLOOR_REGIONS[theme_index], Color(0.62, 0.66, 0.72))
	draw_rect(Rect2(0, 0, 800, 420), Color("344457"), false, 24.0)
	draw_string(ThemeDB.fallback_font, Vector2(300, 5), THEME_NAMES[theme_index], HORIZONTAL_ALIGNMENT_CENTER, 200, 13, Color("f4e4c4"))
	draw_rect(Rect2(750, 170, 38, 80), Color("54d6a8") if door_open else Color("936577"))
	draw_line(Vector2(762, 210), Vector2(780, 210), Color.WHITE, 3.0)
