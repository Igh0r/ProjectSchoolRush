extends SceneTree

const REPORT = preload("res://scripts/systems/run_report.gd")
var failures: int = 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func run_tests() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false) # Tempo determinístico; exercita os mesmos estados do jogo.
	game._process(5.0)
	check(game.run_report.elapsed_seconds == 0.0, "Menu não deve contar tempo")
	check(game.run_report.save_json().error == ERR_UNAVAILABLE, "Partida incompleta não deve salvar")
	game.start_run(1)
	var expected_answers: Array = []
	for index in range(4):
		game._process(2.0)
		game.choose_question(0)
		var question: Dictionary = game.questions.selected.duplicate(true)
		var option: int = (int(question.correct) + 1) % 4 if index == 1 else int(question.correct)
		expected_answers.append(question.options[option])
		game._process(3.0)
		game.answer_question(option)
		game.answer_question(option)
		game._process(1.0)
		game.begin_combat()
		game._process(4.0)
		game.toggle_pause()
		game._process(100.0)
		game.toggle_pause()
		for enemy in game.room.enemies.duplicate():
			enemy.take_damage(1000)
		await process_frame
		game._resolve_room(game.run_epoch)
		if index < 3:
			game._process(1.0)
			game.player.position = game.room.DOOR
			game.advance_room()
	var result: Dictionary = game.run_report.snapshot()
	check(result.outcome == "victory" and result.rooms_cleared == 4, "Vitória deve registrar quatro salas sem duplicar")
	check(result.answered_questions == 4 and result.correct_answers == 3, "Contagem deve distinguir erro e acerto sem duplicar")
	check(result.elapsed_seconds == 43.0 and result.combat_seconds == 16.0, "Tempo deve incluir leitura e excluir pausa")
	check(result.route == game.room.route_name(), "Resumo deve registrar a rota escolhida")
	for index in range(4):
		check(result.answers[index].selected_answer == expected_answers[index], "Registrar texto da alternativa embaralhada")
		check(not result.answers[index].explanation.is_empty(), "Revisão deve preservar explicação")
	check(result.answers[1].reward_status == "none", "Erro não deve receber bônus")
	var attributes: Array = [game.player.health, game.player.damage, game.player.max_health, game.player.speed_bonus_percent]
	for index in range(4):
		game.show_answer_review(index)
		game._process(50.0)
		game.answer_question(0)
		game.begin_combat()
	game.show_answer_review(-1)
	game.show_answer_review(4)
	game.show_run_summary()
	check(game.state == game.State.VICTORY and game.run_report.elapsed_seconds == 43.0, "Revisão deve congelar tempo e combate")
	check(attributes == [game.player.health, game.player.damage, game.player.max_health, game.player.speed_bonus_percent], "Revisar não pode aplicar recompensas")
	result.answers[0].prompt = "alterado"
	check(game.run_report.snapshot().answers[0].prompt != "alterado", "Snapshot deve proteger registro original")
	var directory := "res://builds/report-tests-%d" % Time.get_ticks_usec()
	var saved: Dictionary = game.run_report.save_json(directory)
	check(saved.error == OK, "Exportação local deve funcionar")
	if saved.error == OK:
		var decoded = JSON.parse_string(FileAccess.get_file_as_string(saved.path))
		check(decoded.answers.size() == 4 and decoded.correct_answers == 3 and decoded.game_version == ProjectSettings.get_setting("application/config/version"), "JSON deve preservar respostas e versão")
		check(game.run_report.save_json(directory).path == saved.path, "Salvar novamente deve reutilizar arquivo")
		game.save_run_report(directory)
		check(game.report_notice.contains(ProjectSettings.globalize_path(saved.path)), "Tela deve informar onde o resumo foi salvo")
		var second_report = REPORT.new()
		second_report.result = game.run_report.snapshot()
		check(second_report.save_json(saved.path).error != OK, "Falha ao salvar deve permitir nova tentativa")
		var second_save: Dictionary = second_report.save_json(directory)
		check(second_save.error == OK and second_save.path != saved.path, "Partidas no mesmo segundo não podem sobrescrever arquivos")
		if second_save.error == OK:
			DirAccess.remove_absolute(second_save.path)
		DirAccess.remove_absolute(saved.path)
	DirAccess.remove_absolute(directory)
	var seen_before: int = game.questions.last_seen.size()
	game.start_run()
	check(game.run_report.snapshot().is_empty() and game.run_report.answers.is_empty() and game.run_report.elapsed_seconds == 0 and game.run_report.saved_path.is_empty(), "Reinício deve limpar relatório e caminho")
	check(game.questions.last_seen.size() >= seen_before, "Reinício deve preservar histórico de questões na sessão")
	game.show_answer_review(0)
	game.save_run_report()
	check(game.state == game.State.QUESTION and game.run_report.saved_path.is_empty(), "Callbacks finais devem ignorar partida nova")
	game.choose_question(0)
	game.answer_question(game.questions.selected.correct)
	game.begin_combat()
	for enemy in game.room.enemies.duplicate():
		enemy.take_damage(1000)
	game.player.take_damage(1000)
	await process_frame
	result = game.run_report.snapshot()
	check(result.outcome == "defeat" and result.rooms_cleared == 0 and result.room_reached == 1, "Morte simultânea deve registrar derrota sem sala concluída")
	check(result.correct_answers == 1 and result.answers[0].reward_status == "cancelled", "Derrota deve preservar acerto e cancelar bônus")
	game._on_player_died()
	game._process(10.0)
	check(game.run_report.snapshot() == result, "Resultado final deve ser estável")
	game.show_answer_review(0)
	game.show_menu()
	game._process(10.0)
	check(game.run_report.snapshot() == result, "Menu não deve modificar última partida")
	# Cura no limite: recompensa ganha, sem alteração efetiva.
	var report = REPORT.new()
	report.record_answer({"id": "fixture", "subject": "history", "topic": "tema", "difficulty": "basic", "prompt": "Pergunta", "options": ["certa", "errada"], "correct": 0, "explanation": "Explicação"}, 0, 1, "História")
	report.clear_room(1, false)
	report.clear_room(1, true)
	report.finish("defeat", 2, {})
	check(report.snapshot().answers[0].reward_status == "no_effect" and report.snapshot().rooms_cleared == 1, "Bônus no limite não deve ser descrito como alteração efetiva")
	check(REPORT.format_duration(125.9) == "02:05", "Tempo deve usar minutos e segundos")
	await process_frame
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	print("RUN REPORT TESTS: %d failure(s)" % failures)
	quit(1 if failures else 0)
