extends SceneTree

var failures: int = 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func fight(game: Node) -> void:
	game.choose_question(0)
	game.answer_question(game.questions.selected.correct)
	game.begin_combat()

func run_tests() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.start_run()
	game.toggle_pause()
	check(game.state == game.State.QUESTION and not paused, "Perguntas não devem abrir pausa")
	for index in range(4):
		fight(game)
		check(game.room_index == index, "Ordem das salas incorreta")
		check(game.room.boss_room == (index == 3), "Chefe só pode aparecer na quarta sala")
		if index == 3:
			var boss = game.room.enemies[0]
			check(boss.health == 150 and boss.phase == boss.Phase.WARNING, "Chefe deve começar com aviso")
			var direction: Vector2 = boss.charge_direction
			game.player.position = Vector2(100, 350)
			await physics_frame
			await physics_frame
			check(boss.charge_direction == direction, "Aviso não pode acompanhar o jogador")
			game.toggle_pause()
			var saved_position: Vector2 = boss.position
			var saved_time: float = boss.phase_time
			for i in range(5):
				await physics_frame
			check(boss.position == saved_position and boss.phase_time == saved_time, "Pausa deve congelar movimento e temporizador")
			game.toggle_pause()
			check(not paused and game.state == game.State.COMBAT, "Retomar deve restaurar combate")
			boss.phase_time = 0.001
			await physics_frame
			await physics_frame
			check(boss.phase == boss.Phase.CHARGE, "Aviso deve levar à investida")
			boss.phase_time = 0.001
			await physics_frame
			await physics_frame
			check(boss.phase == boss.Phase.RECOVERY, "Investida deve levar à recuperação")
		for enemy in game.room.enemies.duplicate():
			enemy.take_damage(1000)
		if index == 1:
			game.toggle_pause() # Pausa no mesmo frame da última morte.
		await process_frame
		if index == 1:
			game.toggle_pause()
		if index < 3:
			check(game.state == game.State.CLEARED, "Sala limpa deve liberar saída mesmo com pausa no último golpe")
			game.toggle_pause()
			game.toggle_pause()
			check(game.state == game.State.CLEARED, "Pausa na saída deve restaurar a saída")
			game.player.position = game.room.DOOR
			game.advance_room()
	check(game.state == game.State.VICTORY and not game.player.active, "Chefe morto deve encerrar com vitória")
	check(game.player.damage == 18, "Quatro acertos devem conceder quatro bônus")
	game.start_run()
	game.room_index = 3
	fight(game)
	game.room.enemies[0].take_damage(1000)
	game.player.take_damage(100)
	await process_frame
	check(game.state == game.State.DEFEAT, "Morte simultânea deve priorizar derrota")
	game.start_run()
	fight(game)
	game.toggle_pause()
	game.start_run()
	check(not paused and game.state == game.State.QUESTION, "Reiniciar da pausa deve desbloquear árvore")
	check(game.player.damage == 10 and game.player.health == 100, "Reinício após chefe deve limpar atributos")
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("RUN TESTS: %d failure(s)" % failures)
	quit(1 if failures else 0)
