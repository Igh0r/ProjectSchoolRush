extends SceneTree

var failures: int = 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func run_tests() -> void:
	var manager = load("res://scripts/systems/question_manager.gd").new()
	manager.reset()
	var seen: Array[String] = []
	for question in manager.BANK:
		check(question.options.size() == 4 and question.correct in range(4), "Questão inválida: " + question.id)
		check(not question.explanation.is_empty(), "Explicação ausente")
	for i in range(4):
		var offer = manager.offer()
		check(offer.size() == 2, "É necessário oferecer duas questões por sala")
		for question in offer:
			check(not seen.has(question.id), "Questão repetida na partida")
			seen.append(question.id)
		manager.choose(0)
		manager.answer(manager.selected.correct)
		check(not manager.choose(1), "Não pode trocar pergunta depois da escolha")
		check(not manager.answer(manager.selected.correct), "Não pode responder duas vezes")
		check(manager.consume_reward() == "Matemática", "Acerto de matemática deve reservar dano")
		check(manager.consume_reward().is_empty(), "Recompensa só pode ser consumida uma vez")
	check(seen.size() == 8, "Quatro ofertas devem consumir oito questões")
	manager.reset()
	check(manager.remaining.size() == 10 and manager.pending_reward.is_empty(), "Reset do banco deve repor questões e limpar bônus")

	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.start_run()
	game.choose_question(0)
	game.answer_question(game.questions.selected.correct)
	game.answer_question(game.questions.selected.correct)
	check(game.player.damage == 10, "Resposta correta não deve aplicar bônus antes do combate")
	game.begin_combat()
	game.advance_room()
	check(game.room_index == 0, "Porta fechada não permite avançar")
	for enemy in game.room.enemies.duplicate():
		enemy.take_damage(100)
	await process_frame
	check(game.player.damage == 12, "Concluir a sala deve aplicar o bônus reservado")
	game._resolve_room(game.run_epoch)
	check(game.player.damage == 12, "Sinal duplicado não deve repetir bônus")
	game.advance_room()
	check(game.room_index == 0, "Só pode avançar perto da porta")
	game.player.position = game.room.DOOR
	game.advance_room()
	game.advance_room()
	check(game.room_index == 1 and game.state == game.State.QUESTION, "Interação repetida não deve pular salas")
	game.choose_question(1)
	game.answer_question(game.questions.selected.correct)
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
	game.answer_question((game.questions.selected.correct + 1) % 4)
	game.begin_combat()
	check(game.room.enemies.size() == 4, "Terceira sala deve ter quatro inimigos")
	for enemy in game.room.enemies.duplicate():
		enemy.take_damage(100)
	await process_frame
	check(game.player.damage == 12, "Erro não deve conceder bônus")
	check(game.state == game.State.CLEARED, "Erro deve permitir concluir a sala")
	game.start_run()
	game.choose_question(0)
	game.answer_question(game.questions.selected.correct)
	game.begin_combat()
	game.player.take_damage(100)
	check(game.questions.pending_reward.is_empty() and game.player.damage == 10, "Morrer cancela bônus pendente")
	game.start_run()
	check(game.player.health == 100 and game.player.damage == 10 and game.room_index == 0, "Reset deve limpar progressão")
	game.queue_free()
	await process_frame
	print("PROGRESSION TESTS: %d failure(s)" % failures)
	quit(1 if failures else 0)
