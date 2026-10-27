extends Node2D

const PLAYER_SCENE = preload("res://scenes/player/player.tscn")
const ROOM_SCENE = preload("res://scenes/room/room.tscn")
const UI_SCRIPT = preload("res://scripts/ui/game_ui.gd")
const QUESTIONS = preload("res://scripts/systems/question_manager.gd")
const RUN_REPORT = preload("res://scripts/systems/run_report.gd")
const SOUND_SCRIPT = preload("res://scripts/systems/sound_effects.gd")
const AUDIO_PREFERENCES = preload("res://scripts/systems/audio_preferences.gd")
const CONTROL_TRAINING = preload("res://scripts/systems/control_training.gd")
const QUEST_BGM = preload("res://bgm/Quest Loop.ogg")
const BOSS_BGM = preload("res://bgm/Marche du Roi.ogg")
const DEFEAT_BGM = preload("res://bgm/Defeat.ogg")
const VICTORY_BGM = preload("res://bgm/Victory Chime.ogg")
const DEFEAT_IMAGE = preload("res://assets/history/defeat.png")
const VICTORY_IMAGE = preload("res://assets/history/victory.png")
enum State { MENU, QUESTION, ANSWER, FEEDBACK, COMBAT, CLEARED, DEFEAT, VICTORY, PAUSED, TRAINING, TRAINING_COMPLETE }
var state: State = State.MENU
var previous_state: State = State.COMBAT
var player
var room
var ui
var music: AudioStreamPlayer
var sounds
var training
var questions = QUESTIONS.new()
var room_index: int = 0
var run_epoch: int = 0
var last_reward: String = ""
var run_report = RUN_REPORT.new()
var report_notice: String = ""
var audio_preferences = AUDIO_PREFERENCES.new()
var audio_settings_path: String = "user://audio.cfg"
var audio_settings_open: bool = false
var audio_load_failed: bool = false

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
	var audio_error: Error = audio_preferences.load_from(audio_settings_path)
	audio_load_failed = audio_error != OK and audio_error != ERR_FILE_NOT_FOUND
	_apply_audio_preferences()
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
	training = CONTROL_TRAINING.new()
	add_child(training)
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
	audio_settings_open = false
	training.stop()
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
	ui.show_panel("School Rush", "Acerte perguntas e vença o combate para receber melhorias.\nWASD / setas: mover • Shift: correr • Espaço: régua\nE: sair pela porta • Esc: pausar • M: efeitos sonoros", [{"text": "Rota clássica • Dados, nuvem e centurião", "action": start_run.bind(0)}, {"text": "Expedição científica • Pátio, cacto e cientista", "action": start_run.bind(1)}, {"text": "Áudio", "action": show_audio_settings}, {"text": "Treinar controles • Área segura", "action": start_training}])
	_update_hud()

func start_run(route: int = -1) -> void:
	audio_settings_open = false
	training.stop()
	if not questions.validation_errors.is_empty():
		return
	if route >= 0:
		room.route_index = clampi(route, 0, 1)
	play_music(QUEST_BGM, true)
	get_tree().paused = false
	run_epoch += 1
	state = State.QUESTION
	room_index = 0
	last_reward = ""
	run_report.reset(room.route_name())
	report_notice = ""
	room.clear_enemies()
	player.active = false
	ui.reset_health_feedback()
	player.reset_run()
	questions.reset()
	_prepare_question()

func start_training() -> void:
	audio_settings_open = false
	get_tree().paused = false
	run_epoch += 1
	state = State.TRAINING
	room_index = 0
	last_reward = ""
	report_notice = ""
	room.clear_enemies()
	room.set_room_theme(0)
	questions.reset()
	run_report.reset("")
	ui.reset_health_feedback()
	player.reset_run()
	player.position = room.ENTRY
	player.active = true
	training.start(player, room)
	play_music(QUEST_BGM, true)
	ui.hide_panel()
	_update_hud()

func finish_training() -> void:
	if state != State.TRAINING or training.step != training.Step.EXIT or not room.can_exit(player.position):
		return
	training.finish()
	state = State.TRAINING_COMPLETE
	player.active = false
	room.set_combat(false)
	ui.show_panel("Treino concluído!", "Você praticou movimento, corrida, régua e saída.\nNa partida, acerte uma pergunta e vença a sala para receber o bônus.\nOs inimigos reais atacam: observe os avisos e recue entre golpes.", [
		{"text": "Jogar rota clássica", "action": start_run.bind(0)},
		{"text": "Jogar expedição científica", "action": start_run.bind(1)},
		{"text": "Repetir treino", "action": start_training},
		{"text": "Início", "action": show_menu},
	])
	_update_hud()

func _prepare_question() -> void:
	state = State.QUESTION
	player.active = false
	player.position = room.ENTRY
	room.set_combat(false)
	room.set_room_theme(room_index)
	room.door_open = false
	room.queue_redraw()
	var choices: Array = []
	var offered = questions.offer()
	if offered.size() != 2:
		ui.show_panel("Perguntas indisponíveis", "Não há perguntas suficientes para continuar. Inicie uma nova partida.", [{"text": "Voltar ao início", "action": show_menu}])
		return
	for i in range(offered.size()):
		var question: Dictionary = offered[i]
		choices.append({"text": "%s • %s\n%s\nRecompensa: %s" % [questions.subject_name(question.subject), questions.difficulty_name(question.difficulty), question.prompt, questions.reward_description(question.subject)], "action": choose_question.bind(i)})
	ui.show_panel("Sala %d • Escolha seu desafio" % (room_index + 1), "%s • %s\nProgressão: Fácil → Médio → Médio → Difícil\nAcerte e vença o combate para receber o bônus." % [questions.audience, room.route_name()], choices)
	_update_hud()

func choose_question(index: int) -> void:
	if state != State.QUESTION or not questions.choose(index):
		return
	state = State.ANSWER
	var choices: Array = []
	for i in range(4):
		choices.append({"text": "%s) %s" % [char(65 + i), questions.selected.options[i]], "action": answer_question.bind(i)})
	ui.show_panel(questions.subject_name(questions.selected.subject), "%s • %s\n%s" % [questions.selected.topic, questions.difficulty_name(questions.selected.difficulty), questions.selected.prompt], choices)

func answer_question(index: int) -> void:
	if state != State.ANSWER or index < 0 or index > 3:
		return
	var correct: bool = questions.answer(index)
	run_report.record_answer(questions.selected, index, room_index + 1, questions.subject_name(questions.selected.subject))
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
	_finish_report("defeat")
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
	var changed: bool = false
	if not reward.is_empty():
		changed = player.apply_reward(questions.reward_config(reward))
		last_reward = "Recebido: %s." % questions.reward_description(reward) if changed else "Bônus sem efeito: atributo já no limite."
	run_report.clear_room(room_index + 1, changed)
	if room_index == 3:
		state = State.VICTORY
		player.active = false
		_finish_report("victory")
		_update_hud()
		return
	state = State.CLEARED
	room.open_door()
	_update_hud()

func advance_room() -> void:
	if state == State.TRAINING:
		finish_training()
		return
	if state != State.CLEARED or not room.can_exit(player.position):
		return
	room_index += 1
	_prepare_question()

func toggle_pause() -> void:
	if audio_settings_open:
		close_audio_settings()
		return
	if state == State.PAUSED:
		state = previous_state
		get_tree().paused = false
		ui.hide_panel()
		if state == State.COMBAT and room.enemies.is_empty():
			_resolve_room(run_epoch)
	elif state in [State.COMBAT, State.CLEARED, State.TRAINING]:
		previous_state = state
		state = State.PAUSED
		get_tree().paused = true
		_show_pause_panel()

func _show_pause_panel() -> void:
	if previous_state == State.TRAINING:
		ui.show_panel("Treino pausado", training.instruction() + "\nO treino não consome perguntas nem concede bônus.", [{"text": "Continuar treino", "action": toggle_pause}, {"text": "Áudio", "action": show_audio_settings}, {"text": "Recomeçar treino", "action": start_training}, {"text": "Voltar ao início", "action": show_menu}])
		return
	ui.show_panel("Pausa", "Vida: %d/%d • Régua: %d • Velocidade: +%s%%\n\nWASD / setas: mover • Shift: correr\nEspaço: atacar • E: sair pela porta\nEsc: continuar • M: efeitos sonoros" % [player.health, player.max_health, player.damage, String.num(player.speed_bonus_percent, 1)], [{"text": "Continuar", "action": toggle_pause}, {"text": "Áudio", "action": show_audio_settings}, {"text": "Reiniciar partida", "action": start_run}, {"text": "Voltar ao início", "action": show_menu}])

func show_audio_settings(notice: String = "") -> void:
	if state not in [State.MENU, State.PAUSED]:
		return
	audio_settings_open = true
	if audio_load_failed and notice.is_empty():
		notice = "Não foi possível ler suas preferências. Usando o padrão; salve para tentar novamente."
	ui.show_audio_settings(audio_preferences.music_percent, audio_preferences.effects_percent, audio_preferences.effects_muted, {
		"music": set_music_volume, "effects": set_effects_volume, "mute": set_effects_muted,
		"save": save_audio_settings, "reset": reset_audio_settings, "back": close_audio_settings,
	}, notice)

func _apply_audio_preferences() -> void:
	music.volume_linear = db_to_linear(-8.0) * audio_preferences.music_percent / 100.0
	sounds.set_preferences(audio_preferences.effects_percent, audio_preferences.effects_muted)

func set_music_volume(value: float) -> void:
	if not audio_settings_open:
		return
	audio_preferences.music_percent = clampf(value, 0.0, 100.0)
	_apply_audio_preferences()

func set_effects_volume(value: float) -> void:
	if not audio_settings_open:
		return
	audio_preferences.effects_percent = clampf(value, 0.0, 100.0)
	_apply_audio_preferences()

func set_effects_muted(value: bool) -> void:
	audio_preferences.effects_muted = value
	_apply_audio_preferences()

func reset_audio_settings() -> void:
	if not audio_settings_open:
		return
	audio_preferences.reset()
	_apply_audio_preferences()
	show_audio_settings("Padrão aplicado. Salve para manter ao reabrir.")

func save_audio_settings() -> void:
	if not audio_settings_open:
		return
	if audio_preferences.save_to(audio_settings_path) != OK:
		show_audio_settings("Não foi possível salvar. Os ajustes continuam nesta sessão; tente novamente.")
		return
	audio_load_failed = false
	close_audio_settings()

func close_audio_settings() -> void:
	if not audio_settings_open:
		return
	audio_settings_open = false
	if state == State.PAUSED:
		_show_pause_panel()
	elif state == State.MENU:
		show_menu()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		toggle_pause()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact") and not event.is_echo():
		advance_room()
	elif event.is_action_pressed("mute") and not event.is_echo():
		set_effects_muted(not audio_preferences.effects_muted)
		if audio_settings_open:
			show_audio_settings()

func _process(delta: float) -> void:
	if state in [State.QUESTION, State.ANSWER, State.FEEDBACK, State.COMBAT, State.CLEARED] and not get_tree().paused:
		run_report.advance_time(delta, state == State.COMBAT)
	_update_hud()

func _finish_report(outcome: String) -> void:
	play_music(DEFEAT_BGM if outcome == "defeat" else VICTORY_BGM, outcome == "defeat")
	run_report.finish(outcome, room_index + 1, {
		"health": player.health, "max_health": player.max_health,
		"damage": player.damage, "speed_bonus_percent": player.speed_bonus_percent,
	})
	show_run_summary()

func show_run_summary() -> void:
	if state not in [State.VICTORY, State.DEFEAT]:
		return
	var report: Dictionary = run_report.snapshot()
	var won: bool = state == State.VICTORY
	var description := "Napoleão foi derrotado e o portal se abriu." if won else "Você chegou à sala %d. Tente golpear e recuar entre ataques." % report.room_reached
	description += "\n%s • Salas concluídas: %d/4\nAcertos: %d/%d • Tempo: %s (sem pausas)\nVida: %d/%d • Régua: %d • Velocidade: +%s%%" % [report.route, report.rooms_cleared, report.correct_answers, report.answered_questions, RUN_REPORT.format_duration(report.elapsed_seconds), report.final_attributes.health, report.final_attributes.max_health, report.final_attributes.damage, String.num(report.final_attributes.speed_bonus_percent, 1)]
	if not report_notice.is_empty():
		description += "\n\n" + report_notice
	var choices: Array = [
		{"text": "Rever respostas", "action": show_answer_review.bind(0)},
		{"text": "Salvar resumo neste computador", "action": save_run_report},
	]
	if not run_report.saved_path.is_empty():
		choices.append({"text": "Abrir pasta dos resumos", "action": open_report_folder})
	choices.append_array([
		{"text": "Nova partida" if won else "Tentar novamente", "action": start_run},
		{"text": "Início", "action": show_menu},
	])
	ui.show_panel("Você voltou para casa!" if won else "Fim da partida", description, choices, VICTORY_IMAGE if won else DEFEAT_IMAGE, 360.0 if won else 190.0)

func show_answer_review(index: int) -> void:
	if state not in [State.VICTORY, State.DEFEAT]:
		return
	var report: Dictionary = run_report.snapshot()
	if index < 0 or index >= report.answers.size():
		return
	var answer: Dictionary = report.answers[index]
	var description := "Sala %d • %s • %s\n%s • %s\n\n%s\n\nSua resposta: %s\nResposta correta: %s\n\n%s\n\n%s" % [answer.room, answer.subject_name, answer.id, answer.topic, questions.difficulty_name(answer.difficulty), answer.prompt, answer.selected_answer, answer.correct_answer, answer.explanation, RUN_REPORT.reward_text(answer.reward_status)]
	var choices: Array = []
	if index == 0:
		var levels: Array[String] = []
		for level in ["basic", "intermediate", "challenge"]:
			var count: Dictionary = report.difficulty_breakdown[level]
			levels.append("%s: %d/%d" % [questions.difficulty_name(level), count.correct, count.answered] if count.answered > 0 else "%s: não respondido" % questions.difficulty_name(level))
		description = "Acertos por nível • " + " | ".join(levels) + "\n\n" + description
	if index > 0:
		choices.append({"text": "Resposta anterior", "action": show_answer_review.bind(index - 1)})
	if index + 1 < report.answers.size():
		choices.append({"text": "Próxima resposta", "action": show_answer_review.bind(index + 1)})
	choices.append({"text": "Voltar ao resumo", "action": show_run_summary})
	ui.show_panel("Resposta %d/%d • %s" % [index + 1, report.answers.size(), "Acertou" if answer.correct else "Para revisar"], description, choices)

func save_run_report(directory: String = "user://reports") -> void:
	if state not in [State.VICTORY, State.DEFEAT]:
		return
	var saved: Dictionary = run_report.save_json(directory)
	report_notice = "Resumo salvo em:\n%s\nVocê pode compartilhar esse arquivo com a equipe." % ProjectSettings.globalize_path(saved.path) if saved.error == OK else "Não foi possível salvar o resumo. Confira o espaço e a permissão da pasta e tente novamente."
	show_run_summary()

func open_report_folder() -> void:
	if state not in [State.VICTORY, State.DEFEAT] or run_report.saved_path.is_empty():
		return
	if OS.shell_open(ProjectSettings.globalize_path(run_report.saved_path.get_base_dir())) != OK:
		report_notice = "Não foi possível abrir a pasta. Localize o resumo em:\n" + ProjectSettings.globalize_path(run_report.saved_path)
		show_run_summary()

func _update_hud() -> void:
	if ui == null:
		return
	if state in [State.TRAINING, State.TRAINING_COMPLETE] or (state == State.PAUSED and previous_state == State.TRAINING):
		ui.update_hud(player.health, player.max_health, player.damage, 1, 0, training.instruction())
		ui.header.text = "TREINO • Área segura • Régua %d" % player.damage
		return
	var message := "WASD / setas: mover   •   Shift: correr   •   Espaço: régua"
	if state == State.COMBAT and not questions.pending_reward.is_empty():
		message = "Bônus após a sala: %s   •   Espaço: régua" % questions.reward_description(questions.pending_reward)
	if state == State.COMBAT and room_index == 3:
		message = "NAPOLEÃO   •   Saia da linha ou setor amarelo; ataque quando ABERTO   •   Esc: pausa"
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
