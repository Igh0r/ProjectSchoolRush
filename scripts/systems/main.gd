extends Node2D

const PLAYER_SCENE = preload("res://scenes/player/player.tscn")
const ROOM_SCENE = preload("res://scenes/room/room.tscn")
const UI_SCRIPT = preload("res://scripts/ui/game_ui.gd")
enum State { MENU, COMBAT, CLEARED, DEFEAT }
var state: State = State.MENU
var player
var room
var ui

func _ready() -> void:
	_register_controls()
	room = ROOM_SCENE.instantiate()
	add_child(room)
	var camera := Camera2D.new()
	camera.position = Vector2(400, 210)
	add_child(camera)
	player = PLAYER_SCENE.instantiate()
	add_child(player)
	player.position = room.ENTRY
	player.attacked.connect(room.strike)
	player.died.connect(_on_player_died)
	player.health_changed.connect(func(_value: int): _update_hud())
	room.cleared.connect(_on_room_cleared)
	ui = UI_SCRIPT.new()
	add_child(ui)
	show_menu()

func _register_controls() -> void:
	var bindings := {
		"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP], "move_down": [KEY_S, KEY_DOWN],
		"sprint": [KEY_SHIFT], "attack": [KEY_SPACE], "interact": [KEY_E],
	}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for keycode in bindings[action]:
			var event := InputEventKey.new()
			event.physical_keycode = keycode
			if not InputMap.action_has_event(action, event):
				InputMap.action_add_event(action, event)

func show_menu() -> void:
	state = State.MENU
	player.active = false
	room.clear_enemies()
	ui.show_panel("School Rush", "Protótipo de combate\n\nWASD ou setas: mover  •  Shift: correr\nEspaço: atacar na última direção de movimento\n\nDerrote os dois dados sem perder toda a vida.", [{"text": "Jogar", "action": start_run}])
	_update_hud()

func start_run() -> void:
	player.reset_run()
	player.position = room.ENTRY
	state = State.COMBAT
	player.active = true
	room.populate(0, player)
	ui.hide_panel()
	_update_hud()

func _on_player_died() -> void:
	state = State.DEFEAT
	room.set_combat(false)
	ui.show_panel("Fim da partida", "Tente se aproximar, golpear e recuar entre os ataques.", [{"text": "Tentar novamente", "action": start_run}, {"text": "Início", "action": show_menu}])
	_update_hud()

func _on_room_cleared() -> void:
	if state != State.COMBAT:
		return
	state = State.CLEARED
	player.active = false
	ui.show_panel("Sala concluída", "Os dois dados foram derrotados!", [{"text": "Jogar novamente", "action": start_run}, {"text": "Início", "action": show_menu}])
	_update_hud()

func _process(_delta: float) -> void:
	_update_hud()

func _update_hud() -> void:
	if ui != null:
		ui.update_hud(player.health, player.damage, 1, room.enemies.size(), "WASD / setas: mover   •   Shift: correr   •   Espaço: régua")
