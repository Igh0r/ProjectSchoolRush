extends Node2D

enum Step { MOVE, SPRINT, ATTACK, EXIT, COMPLETE }
const WALK_MARKER := Vector2(300, 210)
const RUN_MARKER := Vector2(500, 210)
const TARGET_POINT := Vector2(620, 210)
const REQUIRED_SPRINT_DISTANCE := 120.0
var step: Step = Step.MOVE
var sprint_distance: float = 0.0
var previous_position := Vector2.ZERO
var player: CharacterBody2D
var arena: Node2D
var running: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	stop()

func start(trainee: CharacterBody2D, room: Node2D) -> void:
	player = trainee
	arena = room
	step = Step.MOVE
	sprint_distance = 0.0
	previous_position = player.global_position
	running = true
	show()
	set_physics_process(true)
	queue_redraw()

func stop() -> void:
	running = false
	set_physics_process(false)
	hide()

func finish() -> void:
	step = Step.COMPLETE
	stop()

func _physics_process(_delta: float) -> void:
	if not running or get_tree().paused:
		return
	var traveled: float = player.global_position.distance_to(previous_position)
	previous_position = player.global_position
	match step:
		Step.MOVE:
			if player.global_position.distance_to(WALK_MARKER) <= 28.0:
				step = Step.SPRINT
		Step.SPRINT:
			if Input.is_action_pressed("sprint") and Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO:
				sprint_distance += traveled
			if sprint_distance >= REQUIRED_SPRINT_DISTANCE and player.global_position.distance_to(RUN_MARKER) <= 28.0:
				step = Step.ATTACK
				# Reutiliza o alcance/dano reais da régua; alvo fica inativo e não ataca.
				arena.spawn_enemy("dice", TARGET_POINT, player)
				arena.combat_active = true
		Step.ATTACK:
			if arena.enemies.is_empty():
				step = Step.EXIT
				arena.open_door()
	queue_redraw()

func instruction() -> String:
	match step:
		Step.MOVE:
			return "1/4 • WASD / setas: vá ao círculo azul. • Esc: pausa"
		Step.SPRINT:
			return "2/4 • Segure Shift e mova até o círculo amarelo. Corrida: %d%%" % mini(100, int(sprint_distance / REQUIRED_SPRINT_DISTANCE * 100.0))
		Step.ATTACK:
			return "3/4 • Aproxime-se, vire para o dado e use Espaço. O alvo não ataca."
		Step.EXIT:
			return "4/4 • Vá à porta verde e pressione E para concluir o treino."
	return "Treino concluído • Escolha uma rota para jogar."

func _draw() -> void:
	if not running:
		return
	var point := WALK_MARKER if step == Step.MOVE else RUN_MARKER
	if step in [Step.MOVE, Step.SPRINT]:
		var color := Color("83e6ff") if step == Step.MOVE else Color("ffdb80")
		draw_circle(point, 28.0, Color(color, 0.18))
		draw_arc(point, 28.0, 0, TAU, 48, color, 3.0)
		draw_string(ThemeDB.fallback_font, point + Vector2(-65, -42), "MOVER ATÉ AQUI" if step == Step.MOVE else "CORRER ATÉ AQUI", HORIZONTAL_ALIGNMENT_CENTER, 130, 14, color)
	elif step == Step.ATTACK:
		draw_string(ThemeDB.fallback_font, TARGET_POINT + Vector2(-70, -56), "ALVO DE TREINO", HORIZONTAL_ALIGNMENT_CENTER, 140, 14, Color("ffdb80"))
