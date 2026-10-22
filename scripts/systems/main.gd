extends Node2D

const PLAYER_SCENE = preload("res://scenes/player/player.tscn")
const ROOM_SCENE = preload("res://scenes/room/room.tscn")
const UI_SCRIPT = preload("res://scripts/ui/game_ui.gd")
const QUESTIONS = preload("res://scripts/systems/question_manager.gd")
const SOUND_SCRIPT = preload("res://scripts/systems/sound_effects.gd")
const QUEST_BGM = preload("res://bgm/Quest Loop.ogg")
const BOSS_BGM = preload("res://bgm/Marche du Roi.ogg")
enum State { MENU, QUESTION, ANSWER, FEEDBACK, COMBAT, CLEARED, DEFEAT, VICTORY, PAUSED }
var state: State = State.MENU
var previous_state: State = State.COMBAT
var player
var room
var ui
var music: AudioStreamPlayer
var sounds
var questions = QUESTIONS.new()
var room_index: int = 0
var run_epoch: int = 0
var last_reward: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_register_controls()
	music = AudioStreamPlayer.new()
	music.name = "BackgroundMusic"
	music.process_mode = Node.PROCESS_MODE_ALWAYS
	music.volume_db = -8.0
	add_child(music)
	sounds = SOUND_SCRIPT.new()
	add_child(sounds)
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
	player.attacked.connect(func(_origin: Vector2, _direction: Vector2, _damage: int): sounds.play_cue("attack"))
	player.hurt.connect(func(): sounds.play_cue("hurt"))
	player.died.connect(_on_player_died)
	player.health_changed.connect(func(_value: int, _maximum: int): _update_hud())
	room.cleared.connect(_on_room_cleared)
	ui = UI_SCRIPT.new()
	add_child(ui)
	show_menu()

func _register_controls() -> void:
	var bindings := {
		"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP], "move_down": [KEY_S, KEY_DOWN],
		"sprint": [KEY_SHIFT], "attack": [KEY_SPACE], "interact": [KEY_E],
		"mute": [KEY_M],
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
	if not questions.validation_errors.is_empty():
		push_error("Catálogo inválido: " + "; ".join(questions.validation_errors))
		ui.show_panel("Conteúdo indisponível", "Não foi possível carregar as perguntas. A partida estará disponível após corrigir o banco de questões.", [])
		return
	ui.show_panel("School Rush", "Preso em um livro, você precisa vencer os desafios para voltar para casa.\n\nEscolha uma pergunta. Acerte para reservar uma melhoria e vença a sala para recebê-la. Errar não impede o avanço.\n\nWASD / setas: mover • Shift: correr • Espaço: régua\nE: sair pela porta • Esc: pausar • M: ligar/desligar som", [{"text": "Iniciar partida", "action": start_run}])
	_update_hud()

func start_run() -> void:
	if not questions.validation_errors.is_empty():
		return
	play_music(QUEST_BGM, true)
	get_tree().paused = false
	run_epoch += 1
	state = State.QUESTION
	room_index = 0
	last_reward = ""
	room.clear_enemies()
	player.active = false
	ui.reset_health_feedback()
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
	if offered.size() != 2:
		ui.show_panel("Perguntas indisponíveis", "Não há perguntas suficientes para continuar. Inicie uma nova partida.", [{"text": "Voltar ao início", "action": show_menu}])
		return
	for i in range(offered.size()):
		var question: Dictionary = offered[i]
		choices.append({"text": "%s • %s\nRecompensa: %s" % [questions.subject_name(question.subject), question.prompt, questions.reward_description(question.subject)], "action": choose_question.bind(i)})
	ui.show_panel("Sala %d • Escolha seu desafio" % (room_index + 1), "%s • Acerte e vença o combate para receber o bônus." % questions.audience, choices)
	_update_hud()

func choose_question(index: int) -> void:
	if state != State.QUESTION or not questions.choose(index):
		return
	state = State.ANSWER
	var choices: Array = []
	for i in range(4):
		choices.append({"text": "%s) %s" % [char(65 + i), questions.selected.options[i]], "action": answer_question.bind(i)})
	ui.show_panel(questions.subject_name(questions.selected.subject), "%s\n%s" % [questions.selected.topic, questions.selected.prompt], choices)

func answer_question(index: int) -> void:
	if state != State.ANSWER or index < 0 or index > 3:
		return
	var correct: bool = questions.answer(index)
	sounds.play_cue("correct" if correct else "wrong")
	state = State.FEEDBACK
	var result := "Acertou!" if correct else "Ainda dá para vencer!"
	var reward_text := "Bônus reservado: %s." % questions.reward_description(questions.pending_reward) if correct else "Sem bônus nesta sala. Você pode avançar normalmente."
	var tip: String = room.encounter_tip(room_index)
	ui.show_panel(result, "%s\n\nResposta correta: %s\n%s\n\n%s" % [reward_text, questions.selected.options[int(questions.selected.correct)], questions.selected.explanation, tip], [{"text": "Entrar no combate", "action": begin_combat}])

func begin_combat() -> void:
	if state != State.FEEDBACK:
		return
	if room_index == 3:
		play_music(BOSS_BGM, false)
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
	sounds.play_cue("clear")
	last_reward = "Sem bônus nesta sala."
	if not reward.is_empty():
		var changed: bool = player.apply_reward(questions.reward_config(reward))
		last_reward = "Recebido: %s." % questions.reward_description(reward) if changed else "Bônus sem efeito: atributo já no limite."
	if room_index == 3:
		state = State.VICTORY
		player.active = false
		ui.show_panel("Você voltou para casa!", "Napoleão foi derrotado e o livro se abriu.\nVocê concluiu as quatro salas de School Rush.\n\nVida: %d/%d • Régua: %d • Velocidade: +%s%%" % [player.health, player.max_health, player.damage, String.num(player.speed_bonus_percent, 1)], [{"text": "Nova partida", "action": start_run}, {"text": "Início", "action": show_menu}])
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
		ui.show_panel("Pausa", "Vida: %d/%d • Régua: %d • Velocidade: +%s%%\n\nWASD / setas: mover • Shift: correr\nEspaço: atacar • E: sair pela porta\nEsc: continuar • M: ligar/desligar som" % [player.health, player.max_health, player.damage, String.num(player.speed_bonus_percent, 1)], [{"text": "Continuar", "action": toggle_pause}, {"text": "Reiniciar partida", "action": start_run}, {"text": "Voltar ao início", "action": show_menu}])

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		toggle_pause()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact") and not event.is_echo():
		advance_room()
	elif event.is_action_pressed("mute") and not event.is_echo():
		sounds.toggle_mute()

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
	ui.update_hud(player.health, player.max_health, player.damage, room_index + 1, room.enemies.size(), message)

func play_music(stream: AudioStream, looping: bool) -> void:
	var ogg := stream as AudioStreamOggVorbis
	if ogg != null:
		ogg.loop = looping
	if music.stream == stream and music.playing:
		return
	music.stream = stream
	music.play()
