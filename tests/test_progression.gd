extends SceneTree

var failures: int = 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func select_subject(game: Node, subject_id: String) -> void:
	for i in range(game.questions.offered.size()):
		if game.questions.offered[i].subject == subject_id:
			game.choose_question(i)
			return
	check(false, "Matéria esperada não foi oferecida: " + subject_id)

func run_tests() -> void:
	var manager = load("res://scripts/systems/question_manager.gd").new()
	check(manager.validation_errors.is_empty(), "Banco deve passar na validação")
	check(manager.bank.size() == 20 and manager.subjects.size() == 4, "Banco deve conter vinte questões e quatro matérias")
	check(manager.audience == "Ensino Médio", "Público deve ser Ensino Médio")
	for seed_value in range(50):
		manager.rng.seed = seed_value
		manager.reset()
		var seen: Array[String] = []
		var counts: Dictionary = {}
		for i in range(4):
			var offer = manager.offer()
			check(offer.size() == 2 and offer[0].subject != offer[1].subject, "Oferta deve ter duas matérias distintas")
			for question in offer:
				check(not seen.has(question.id), "Questão repetida na partida")
				seen.append(question.id)
				counts[question.subject] = counts.get(question.subject, 0) + 1
			manager.choose(0)
			manager.answer(int(manager.selected.correct))
			check(not manager.choose(1), "Não pode trocar pergunta depois da escolha")
			check(not manager.answer(int(manager.selected.correct)), "Não pode responder duas vezes")
			check(manager.consume_reward() == manager.selected.subject, "Bônus deve corresponder à matéria escolhida")
			check(manager.consume_reward().is_empty(), "Recompensa só pode ser consumida uma vez")
			if i == 1:
				check(counts.size() == 4, "As quatro matérias devem aparecer nas primeiras duas salas")
		check(seen.size() == 8 and counts.size() == 4, "Quatro ofertas devem apresentar oito questões de quatro matérias")
		for count in counts.values():
			check(count == 2, "Cada matéria deve ser oferecida duas vezes por partida")
	manager.reset()
	for i in range(10):
		check(manager.offer().size() == 2, "Banco deve sustentar dez ofertas sem repetição")
	check(manager.offer().is_empty(), "Banco esgotado deve retornar oferta vazia")
	manager.reset()
	check(manager.remaining.size() == 20 and manager.pending_reward.is_empty(), "Reset deve repor todo o banco")

	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	# Uma sequência real em que História fica disponível para a segunda sala.
	var found := false
	for seed_value in range(50):
		game.questions.rng.seed = seed_value
		game.start_run()
		var ids: Array = []
		for question in game.questions.offered:
			ids.append(question.subject)
		if ids.has("math") and not ids.has("history"):
			found = true
			break
	check(found, "Sequência de teste deve oferecer Matemática antes de História")
	select_subject(game, "math")
	game.answer_question(int(game.questions.selected.correct))
	game.answer_question(int(game.questions.selected.correct))
	check(game.player.damage == 10, "Acerto não deve aplicar bônus antes do combate")
	game.begin_combat()
	game.advance_room()
	check(game.room_index == 0, "Porta fechada não permite avançar")
	for enemy in game.room.enemies.duplicate():
		enemy.take_damage(100)
	await process_frame
	check(game.player.damage == 12, "Concluir sala deve aplicar bônus reservado")
	game._resolve_room(game.run_epoch)
	check(game.player.damage == 12, "Sinal duplicado não deve repetir bônus")
	game.advance_room()
	check(game.room_index == 0, "Só pode avançar perto da porta")
	game.player.position = game.room.DOOR
	game.advance_room()
	game.advance_room()
	check(game.room_index == 1 and game.state == game.State.QUESTION, "Interação repetida não deve pular salas")
	select_subject(game, "history")
	game.answer_question(int(game.questions.selected.correct))
	game.begin_combat()
	check(game.room.enemies.size() == 3, "Segunda sala deve ter três inimigos")
	game.player.health = 95
	for enemy in game.room.enemies.duplicate():
		enemy.take_damage(100)
	await process_frame
	check(game.player.health == 100, "Cura não deve ultrapassar a vida máxima")
	game.player.position = game.room.DOOR
	game.advance_room()
	game.choose_question(0)
	game.answer_question((int(game.questions.selected.correct) + 1) % 4)
	game.begin_combat()
	check(game.room.enemies.size() == 4, "Terceira sala deve ter quatro inimigos")
	for enemy in game.room.enemies.duplicate():
		enemy.take_damage(100)
	await process_frame
	check(game.player.damage == 12 and game.player.max_health == 100 and game.player.speed_bonus_percent == 0, "Erro não deve conceder bônus")
	check(game.state == game.State.CLEARED, "Erro deve permitir concluir a sala")
	game.start_run()
	game.choose_question(0)
	game.answer_question(int(game.questions.selected.correct))
	game.begin_combat()
	game.player.take_damage(100)
	check(game.questions.pending_reward.is_empty(), "Morrer cancela bônus pendente")
	game.start_run()
	check(game.player.health == 100 and game.player.damage == 10 and game.room_index == 0, "Reset deve limpar progressão")
	await process_frame
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("PROGRESSION TESTS: %d failure(s)" % failures)
	quit(1 if failures else 0)
