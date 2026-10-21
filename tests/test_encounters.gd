extends SceneTree

var failures: int = 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func begin_room(game: Node) -> void:
	game.choose_question(0)
	game.answer_question((int(game.questions.selected.correct) + 1) % 4)
	game.begin_combat()

func spawn_shot(game: Node) -> void:
	for enemy in game.room.enemies:
		if enemy.has_signal("shot_requested"):
			enemy.shot_requested.emit(enemy, Vector2(600, 100), Vector2.LEFT)

func run_tests() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.start_run()
	var expected := [["dice", "dice"], ["dice", "dice", "cloud"], ["dice", "dice", "cloud", "centurion"], ["boss"]]
	for index in range(4):
		check(game.room.projectiles.is_empty(), "Perguntas devem iniciar sem projéteis")
		begin_room(game)
		check(game.room.enemies.size() == expected[index].size(), "Quantidade por sala deve respeitar introdução gradual")
		for i in range(game.room.enemies.size()):
			var enemy = game.room.enemies[i]
			check(enemy.scene_file_path == "res://scenes/enemies/%s.tscn" % expected[index][i], "Composição da sala está incorreta")
			check(enemy.position.distance_to(game.room.ENTRY) >= 160.0, "Spawn deve dar espaço seguro na entrada")
			check(enemy.active, "Todos os tipos devem iniciar ativos no combate")
		check(not game.room.door_open, "Porta deve começar fechada")
		spawn_shot(game)
		if index in [1, 2]:
			check(game.room.projectiles.size() == 1, "Nuvem deve disparar nas salas integradas")
		game.room.enemies[0].take_damage(1000)
		if index < 3:
			check(not game.room.enemies.is_empty() and not game.room.door_open, "Matar só um inimigo não libera saída")
			for enemy in game.room.enemies.duplicate():
				enemy.take_damage(1000)
		await process_frame
		check(game.room.projectiles.is_empty(), "Concluir sala deve remover todos os perigos")
		check(game.player.damage == 10 and game.player.max_health == 100 and game.player.speed_bonus_percent == 0, "É possível progredir sem bônus após erros")
		if index < 3:
			check(game.state == game.State.CLEARED, "Encontro misto deve liberar saída")
			game.player.position = game.room.DOOR
			game.advance_room()
		else:
			check(game.state == game.State.VICTORY, "Sequência deve terminar no chefe")
	# Um tiro em voo não pode sobreviver a derrota, menu ou reinício da pausa.
	for action in ["defeat", "menu", "restart"]:
		game.start_run()
		game.room_index = 1
		begin_room(game)
		spawn_shot(game)
		var shot = game.room.projectiles[0]
		if action == "defeat":
			game.player.take_damage(1000)
			check(game.state == game.State.DEFEAT, "Dano letal deve encerrar encontro misto")
		elif action == "menu":
			game.toggle_pause()
			game.show_menu()
		else:
			game.toggle_pause()
			game.start_run()
		check(not shot.active and game.room.projectiles.is_empty(), "Transição deve cancelar tiros imediatamente: " + action)
		check(not paused, "Transição deve destravar a árvore: " + action)
		await process_frame
	await process_frame
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("ENCOUNTERS TESTS: %d failure(s)" % failures)
	quit(1 if failures else 0)
