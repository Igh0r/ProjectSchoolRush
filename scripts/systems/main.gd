extends Node2D

const PLAYER_SCENE = preload("res://scenes/player/player.tscn")
const ROOM_SCENE = preload("res://scenes/room/room.tscn")
const UI_SCRIPT = preload("res://scripts/ui/game_ui.gd")
const QUESTIONS = preload("res://scripts/systems/question_manager.gd")
enum State { MENU, QUESTION, ANSWER, FEEDBACK, COMBAT, CLEARED, DEFEAT, VICTORY, PAUSED }
var state: State = State.MENU
var previous_state: State = State.COMBAT
var player
var room
var ui
var questions = QUESTIONS.new()
var room_index: int = 0
var run_epoch: int = 0
var last_reward: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_register_controls()
	room = ROOM_SCENE.instantiate()
	room.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(room)
	var camera := Camera2D.new()
	camera.position = Vector2(400, 210)
	add_child(camera)
	player = PLAYER_SCENE.instantiate()
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
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
	get_tree().paused = false
	run_epoch += 1
	state = State.MENU
	player.active = false
	room.clear_enemies()
	questions.reset()
	ui.show_panel("School Rush", "Preso em um livro, você precisa vencer os desafios para voltar para casa.\n\nEscolha uma pergunta. Acerte para reservar uma melhoria e vença a sala para recebê-la. Errar não impede o avanço.\n\nWASD / setas: mover • Shift: correr • Espaço: régua\nE: sair pela porta • Esc: pausar", [{"text": "Iniciar partida", "action": start_run}])
	_update_hud()

func start_run() -> void:
	get_tree().paused = false
	run_epoch += 1
	state = State.QUESTION
	room_index = 0
	last_reward = ""
	room.clear_enemies()
	player.active = false
	player.reset_run()
	questions.reset()
	_prepare_question()

func _prepare_question() -> void:
	state = State.QUESTION
	player.active = false
	player.position = room.ENTRY
	room.set_combat(false)
	room.door_open = false
	room.queue_redraw()
	var choices: Array = []
	var offered = questions.offer()
	for i in range(offered.size()):
		var question: Dictionary = offered[i]
		choices.append({"text": "%s • %s\nRecompensa: %s" % [question.subject, question.prompt, questions.reward_description(question.subject)], "action": choose_question.bind(i)})
	ui.show_panel("Sala %d • Escolha seu desafio" % (room_index + 1), "A recompensa só será concedida se você acertar e concluir o combate.", choices)
	_update_hud()

func choose_question(index: int) -> void:
	if state != State.QUESTION or not questions.choose(index):
		return
	state = State.ANSWER
	var choices: Array = []
	for i in range(4):
		choices.append({"text": "%s) %s" % [char(65 + i), questions.selected.options[i]], "action": answer_question.bind(i)})
	ui.show_panel(questions.selected.subject, questions.selected.prompt, choices)

func answer_question(index: int) -> void:
	if state != State.ANSWER or index < 0 or index > 3:
		return
	var correct: bool = questions.answer(index)
	state = State.FEEDBACK
	var result := "Acertou!" if correct else "Ainda dá para vencer!"
	var reward_text := "Bônus reservado: %s." % questions.reward_description(questions.pending_reward) if correct else "Sem bônus nesta sala. Você pode avançar normalmente."
	var tip := "Napoleão espera no ginásio! A linha amarela avisa a direção da investida. Saia da linha e ataque durante a recuperação." if room_index == 3 else "Vença os inimigos para liberar a saída."
	ui.show_panel(result, "%s\n\nResposta correta: %s\n%s\n\n%s" % [reward_text, questions.selected.options[questions.selected.correct], questions.selected.explanation, tip], [{"text": "Entrar no combate", "action": begin_combat}])

func begin_combat() -> void:
	if state != State.FEEDBACK:
		return
	state = State.COMBAT
	player.active = true
	room.populate(room_index, player)
	ui.hide_panel()
	_update_hud()

func _on_player_died() -> void:
	if state != State.COMBAT:
		return
	state = State.DEFEAT
	questions.consume_reward()
	room.set_combat(false)
	ui.show_panel("Fim da partida", "Você chegou à sala %d.\nAproxime-se, golpeie e recue entre os ataques." % (room_index + 1), [{"text": "Tentar novamente", "action": start_run}, {"text": "Início", "action": show_menu}])
	_update_hud()

func _on_room_cleared() -> void:
	# Espera o fim do frame: morte do jogador tem precedência sobre vitória.
	_resolve_room.call_deferred(run_epoch)

func _resolve_room(epoch: int) -> void:
	if epoch != run_epoch or state != State.COMBAT or player.health <= 0 or not room.enemies.is_empty():
		return
	var reward: String = questions.consume_reward()
	last_reward = "Sem bônus nesta sala."
	if reward == "Matemática":
		player.damage += 2
	elif reward == "História":
		player.heal(20)
	if not reward.is_empty():
		last_reward = "Recebido: %s." % questions.reward_description(reward)
	if room_index == 3:
		state = State.VICTORY
		player.active = false
		ui.show_panel("Você voltou para casa!", "Napoleão foi derrotado e o livro se abriu.\nVocê concluiu as quatro salas de School Rush.\n\nVida restante: %d/100 • Dano da régua: %d" % [player.health, player.damage], [{"text": "Nova partida", "action": start_run}, {"text": "Início", "action": show_menu}])
		_update_hud()
		return
	state = State.CLEARED
	room.open_door()
	_update_hud()

func advance_room() -> void:
	if state != State.CLEARED or not room.can_exit(player.position):
		return
	room_index += 1
	_prepare_question()

func toggle_pause() -> void:
	if state == State.PAUSED:
		state = previous_state
		get_tree().paused = false
		ui.hide_panel()
		if state == State.COMBAT and room.enemies.is_empty():
			_resolve_room(run_epoch)
	elif state in [State.COMBAT, State.CLEARED]:
		previous_state = state
		state = State.PAUSED
		get_tree().paused = true
		ui.show_panel("Pausa", "WASD / setas: mover • Shift: correr\nEspaço: atacar • E: sair pela porta\nEsc: continuar", [{"text": "Continuar", "action": toggle_pause}, {"text": "Reiniciar partida", "action": start_run}, {"text": "Voltar ao início", "action": show_menu}])

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		toggle_pause()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact") and not event.is_echo():
		advance_room()

func _process(_delta: float) -> void:
	_update_hud()

func _update_hud() -> void:
	if ui == null:
		return
	var message := "WASD / setas: mover   •   Shift: correr   •   Espaço: régua"
	if state == State.COMBAT and not questions.pending_reward.is_empty():
		message = "Bônus após a sala: %s   •   Espaço: régua" % questions.reward_description(questions.pending_reward)
	if state == State.COMBAT and room_index == 3:
		message = "NAPOLEÃO   •   Desvie da linha amarela e ataque na recuperação   •   Esc: pausa"
	elif state == State.CLEARED:
		message = "%s Vá à porta verde e pressione E." % last_reward
	ui.update_hud(player.health, player.damage, room_index + 1, room.enemies.size(), message)
