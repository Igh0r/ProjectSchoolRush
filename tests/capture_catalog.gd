extends SceneTree

# Rodar com renderização: godot --path . --script res://tests/capture_catalog.gd
var failures := 0

func _initialize() -> void:
	call_deferred("capture")

func save_preview(game: Node, filename: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	if game.ui.content.size.x > game.ui.scroll.size.x + 1.0:
		failures += 1
		push_error("Conteúdo excede a largura do painel: " + filename)
	var result := root.get_texture().get_image().save_png("res://builds/previews/d1/" + filename + ".png")
	if result != OK:
		failures += 1
		push_error("Falha ao salvar captura: " + filename)

func capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://builds/previews/d1")
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	# Ofertas determinísticas com textos extensos; usa o fluxo real de resposta/feedback.
	for resolution in [Vector2i(960, 540), Vector2i(1280, 720)]:
		root.size = resolution
		game.start_run()
		var prefix := str(resolution.x) + "-"
		var long_questions: Array = game.questions.bank.duplicate(true)
		long_questions.sort_custom(func(a, b): return a.prompt.length() > b.prompt.length())
		game.questions.offered.clear()
		game.questions.offered.append(long_questions[0])
		for question in long_questions:
			if question.subject != long_questions[0].subject:
				game.questions.offered.append(question)
				break
		var choices: Array = []
		for i in range(2):
			var question: Dictionary = game.questions.offered[i]
			choices.append({"text": "%s • %s\n%s\nRecompensa: %s" % [game.questions.subject_name(question.subject), game.questions.difficulty_name(question.difficulty), question.prompt, game.questions.reward_description(question.subject)], "action": game.choose_question.bind(i)})
		game.ui.show_panel("Prévia de textos extensos", "Ensino Médio • Rota clássica\nProgressão: Fácil → Médio → Médio → Difícil\nAcerte e vença o combate para receber o bônus.", choices)
		await save_preview(game, prefix + "choice")
		for question_id in ["mat18", "his9", "his19", "cie15", "por19", "mat20", "cie10", "por9", "por15", "por20"]:
			game.start_run()
			for question in game.questions.bank:
				if question.id == question_id:
					game.questions.offered[0] = question.duplicate(true)
					break
			game.choose_question(0)
			await save_preview(game, prefix + question_id + "-answer")
			if game.ui.content.size.y > game.ui.scroll.size.y:
				var last_button: Control = game.ui.content.get_child(game.ui.content.get_child_count() - 1)
				last_button.grab_focus()
				game.ui.scroll.ensure_control_visible(last_button)
				await save_preview(game, prefix + question_id + "-last-option")
				var bounds: Rect2 = game.ui.scroll.get_global_rect()
				if not bounds.grow(1.0).encloses(last_button.get_global_rect()):
					failures += 1
					push_error("Última alternativa inacessível: " + question_id)
			game.answer_question(int(game.questions.selected.correct))
			await save_preview(game, prefix + question_id + "-feedback")
	await process_frame
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	print("CATALOG CAPTURES: %d failure(s)" % failures)
	quit(1 if failures else 0)
