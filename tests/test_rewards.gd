extends SceneTree

var failures: int = 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func start_with_subject(game: Node, subject_id: String) -> void:
	for seed_value in range(50):
		game.questions.rng.seed = seed_value
		game.start_run()
		for i in range(game.questions.offered.size()):
			if game.questions.offered[i].subject == subject_id:
				game.choose_question(i)
				return
	check(false, "Não foi possível oferecer " + subject_id)

func run_tests() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	for subject_id in ["math", "history", "science", "portuguese"]:
		start_with_subject(game, subject_id)
		game.player.health = 80
		game.answer_question(int(game.questions.selected.correct))
		check(game.player.health == 80 and game.player.max_health == 100 and game.player.damage == 10 and game.player.speed_bonus_percent == 0, "Nenhum bônus deve ser aplicado na resposta")
		game.begin_combat()
		for enemy in game.room.enemies.duplicate():
			enemy.take_damage(1000)
		await process_frame
		match subject_id:
			"math":
				check(game.player.damage == 12, "Matemática deve conceder dano")
			"history":
				check(game.player.health == 100 and game.player.max_health == 100, "História deve curar sem ampliar o limite")
			"science":
				check(game.player.health == 90 and game.player.max_health == 110, "Ciências deve ampliar o limite e curar")
				check(game.ui.health_bar.value == 90 and game.ui.health_bar.max_value == 110, "Barra deve acompanhar bônus de Ciências")
			"portuguese":
				check(is_equal_approx(game.player.movement_speed(), 241.5), "Português deve aumentar velocidade em 5% da base")
		var snapshot: Array = [game.player.health, game.player.max_health, game.player.damage, game.player.speed_bonus_percent]
		game._resolve_room(game.run_epoch)
		check(snapshot == [game.player.health, game.player.max_health, game.player.damage, game.player.speed_bonus_percent], "Bônus não pode ser aplicado duas vezes")
		game.player.position = game.room.DOOR
		game.advance_room()
		check(snapshot == [game.player.health, game.player.max_health, game.player.damage, game.player.speed_bonus_percent], "Atributos devem persistir ao avançar")
		start_with_subject(game, subject_id)
		game.answer_question(int(game.questions.selected.correct))
		game.begin_combat()
		game.player.take_damage(1000)
		await process_frame
		check(game.questions.pending_reward.is_empty() and game.player.damage == 10 and game.player.max_health == 100 and game.player.speed_bonus_percent == 0, "Derrota deve cancelar qualquer bônus pendente")
	game.start_run()
	var speed_reward: Dictionary = game.questions.reward_config("portuguese")
	for i in range(5):
		game.player.apply_reward(speed_reward)
	check(game.player.speed_bonus_percent == 20 and is_equal_approx(game.player.movement_speed(), 276), "Velocidade deve somar percentuais da base e respeitar limite de 20%")
	check(not game.player.apply_reward(speed_reward), "Recompensa no limite deve informar ausência de efeito")
	game.player.apply_reward(game.questions.reward_config("science"))
	game.start_run()
	check(game.player.speed_bonus_percent == 0 and game.player.max_health == 100 and game.player.health == 100, "Reinício deve limpar bônus novos")
	# A configuração é copiada, para não permitir mutação acidental do catálogo.
	speed_reward.amount = 99
	check(game.questions.reward_config("portuguese").amount == 5, "Cópia da recompensa não deve alterar catálogo")
	await process_frame
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("REWARDS TESTS: %d failure(s)" % failures)
	quit(1 if failures else 0)
