extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func fight(game: Node) -> void:
	game.choose_question(0)
	game.answer_question(int(game.questions.selected.correct))
	game.begin_combat()

func run_tests() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	var menu_buttons: Array = game.ui.content.get_children().filter(func(child: Node): return child is Button)
	check(menu_buttons.size() == 3 and menu_buttons[2].text == "Áudio", "Menu deve oferecer duas rotas e ajustes de áudio")
	menu_buttons[1].pressed.emit()
	check(game.room.route_index == 1 and game.room.theme_index == 0, "Selecionar expedição deve iniciar pela sala de aula")
	var expected := [["dice", "dice"], ["dice", "cactus", "cloud"], ["dice", "centurion", "scientist", "cloud"], ["boss"]]
	for index in range(4):
		fight(game)
		check(game.room.theme_index == index, "Rota científica deve trocar ambiente por sala")
		check(game.room.enemies.size() == expected[index].size(), "Quantidade de monstros da rota incorreta")
		for i in range(game.room.enemies.size()):
			var enemy = game.room.enemies[i]
			check(enemy.scene_file_path == "res://scenes/enemies/%s.tscn" % expected[index][i], "Composição da rota incorreta")
			check(enemy.position.distance_to(game.room.ENTRY) >= 160.0, "Novos inimigos precisam de spawn seguro")
		for enemy in game.room.enemies.duplicate():
			enemy.take_damage(1000)
		await process_frame
		check(game.room.mixtures.is_empty() and game.room.projectiles.is_empty(), "Sala concluída não pode deixar perigos")
		if index < 3:
			game.player.position = game.room.DOOR
			game.advance_room()
	check(game.state == game.State.VICTORY, "Nova rota deve terminar em vitória")
	game.start_run()
	check(game.room.route_index == 1 and game.player.damage == 10, "Reinício deve manter rota e limpar bônus")
	fight(game)
	game.room.clear_enemies()
	game.room.set_combat(true)
	game.player.position = Vector2(400, 210)
	var cactus = game.room.spawn_enemy("cactus", Vector2(600, 210), game.player)
	var scientist = game.room.spawn_enemy("scientist", Vector2(600, 300), game.player)
	cactus.set_physics_process(false)
	scientist.set_physics_process(false)
	var initial_direction: Vector2 = cactus.shot_direction
	game.player.position = Vector2(400, 290)
	cactus._physics_process(0.4)
	check(game.room.projectiles.is_empty() and cactus.shot_direction == initial_direction, "Cacto deve anunciar mira fixa sem atirar antes da hora")
	cactus._physics_process(0.56)
	check(game.room.projectiles.size() == 3, "Cacto deve disparar três espinhos")
	var directions: Array[Vector2] = []
	for shot in game.room.projectiles:
		shot.set_physics_process(false)
		directions.append(shot.direction)
		check(shot.damage == 8 and shot.speed == 170 and shot.thorn, "Espinhos devem ter configuração própria")
	check(not directions[0].is_equal_approx(directions[1]) and not directions[1].is_equal_approx(directions[2]), "Espinhos devem cobrir três direções distintas")
	check(directions[1].is_equal_approx(initial_direction), "Espinho central deve respeitar mira anunciada")
	cactus._physics_process(0.2)
	check(game.room.projectiles.size() == 3 and cactus.position == Vector2(600, 210), "Cacto deve ficar parado e respeitar recuperação")
	scientist._physics_process(0.01)
	check(game.room.mixtures.size() == 1, "Cientista deve marcar uma mistura")
	var mixture = game.room.mixtures[0]
	mixture.set_physics_process(false)
	var point: Vector2 = mixture.global_position
	var before: int = game.player.health
	mixture._physics_process(0.5)
	check(game.player.health == before and mixture.warning, "Círculo de aviso não pode causar dano")
	game.player.position += Vector2(-100, 0)
	mixture._physics_process(0.51)
	check(mixture.global_position == point and game.player.health == before and not mixture.warning, "Sair do ponto marcado deve evitar mistura")
	game.player.position = point
	game.player.invulnerability = 0.0
	mixture._physics_process(0.01)
	check(game.player.health == before - 10, "Entrar na mistura ativa deve causar dano")
	game.player.invulnerability = 0.0
	mixture._physics_process(0.2)
	check(game.player.health == before - 10, "Cada mistura deve causar no máximo um acerto")
	mixture._physics_process(1.0)
	check(game.room.mixtures.is_empty(), "Mistura deve expirar após janela ativa")
	scientist.phase = scientist.Phase.APPROACH
	scientist._physics_process(0.01)
	mixture = game.room.mixtures[0]
	var remaining: float = mixture.phase_time
	var shot = game.room.projectiles[0]
	shot.set_physics_process(true)
	var shot_position: Vector2 = shot.position
	game.toggle_pause()
	for i in range(5):
		await physics_frame
	check(mixture.phase_time == remaining and shot.position == shot_position, "Pausa deve congelar misturas e espinhos")
	game.toggle_pause()
	shot.set_physics_process(false)
	scientist.take_damage(1000)
	check(game.room.mixtures.is_empty() and not mixture.active, "Morte do cientista deve cancelar mistura imediatamente")
	cactus.take_damage(1000)
	check(game.room.projectiles.is_empty(), "Morte do cacto deve cancelar seus espinhos")
	await process_frame
	# Menu, derrota e reinício precisam limpar uma mistura ainda em aviso.
	for action in ["menu", "defeat", "restart"]:
		game.start_run(1)
		game.room_index = 2
		fight(game)
		for enemy in game.room.enemies:
			if enemy.has_signal("mixture_requested"):
				enemy.mixture_requested.emit(enemy, game.player.global_position)
		mixture = game.room.mixtures[0]
		if action == "menu":
			game.toggle_pause()
			game.show_menu()
		elif action == "defeat":
			game.player.take_damage(1000)
		else:
			game.toggle_pause()
			game.start_run()
		check(game.room.mixtures.is_empty() and not mixture.active, "Transição deve remover mistura: " + action)
		await process_frame
	game.show_menu()
	menu_buttons = game.ui.content.get_children().filter(func(child: Node): return child is Button)
	menu_buttons[0].pressed.emit()
	check(game.room.route_index == 0 and game.room.theme_index == 0, "Menu deve permitir voltar à rota clássica")
	await process_frame
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	print("SCIENCE ROUTE TESTS: %d failure(s)" % failures)
	quit(1 if failures else 0)
