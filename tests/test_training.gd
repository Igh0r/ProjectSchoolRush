extends SceneTree

var failures: int = 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func move_until_step(game: Node, expected: int, sprint: bool = false) -> void:
	Input.action_press("move_right")
	if sprint:
		Input.action_press("sprint")
	for frame in range(150):
		await physics_frame
		if game.training.step == expected:
			break
	Input.action_release("move_right")
	Input.action_release("sprint")
	check(game.training.step == expected, "Movimento real deve concluir a etapa de treino")

func run_tests() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.start_run(1)
	game.show_menu()
	var history: Dictionary = game.questions.last_seen.duplicate(true)
	game.ui.content.get_child(5).pressed.emit() # Treino no menu, após duas rotas e áudio.
	check(game.state == game.State.TRAINING and game.player.active, "Menu deve iniciar treino opcional")
	check(game.room.enemies.is_empty() and not game.room.combat_active and not game.room.door_open, "Treino deve começar seguro e com saída fechada")
	game.advance_room()
	check(game.state == game.State.TRAINING, "E não deve pular etapas")
	await move_until_step(game, game.training.Step.SPRINT)
	check(game.player.health == 100, "Movimento no treino não deve causar dano")
	# Segurar Shift parado, inclusive encostado na parede, não conta distância.
	Input.action_press("sprint")
	for frame in range(5):
		await physics_frame
	Input.action_release("sprint")
	check(game.training.sprint_distance == 0.0, "Shift parado não completa corrida")
	game.player.position = Vector2(773, 210)
	game.training.previous_position = game.player.position
	Input.action_press("move_right")
	Input.action_press("sprint")
	for frame in range(15):
		await physics_frame
	Input.action_release("move_right")
	Input.action_release("sprint")
	check(game.training.sprint_distance < 5.0 and game.training.step == game.training.Step.SPRINT, "Correr contra parede não deve cumprir meta")
	game.player.position = game.training.WALK_MARKER
	game.training.previous_position = game.player.position
	await move_until_step(game, game.training.Step.ATTACK, true)
	check(game.room.enemies.size() == 1 and not game.room.enemies[0].active, "Alvo deve usar dado sem ativar ataques")
	var target = game.room.enemies[0]
	var target_position: Vector2 = target.position
	var health_before: int = target.health
	game.player.facing = Vector2.RIGHT
	game.player.attack()
	check(target.health == health_before, "Golpe distante não deve acertar alvo")
	game.player.position = target.position + Vector2(-40, 0)
	game.player.facing = Vector2.LEFT
	game.player.attack_cooldown = 0
	game.player.attack()
	check(target.health == health_before, "Golpe de costas não deve acertar alvo")
	game.toggle_pause()
	game.show_audio_settings()
	var player_position: Vector2 = game.player.position
	var step_before: int = game.training.step
	Input.action_press("attack")
	Input.action_press("move_right")
	for frame in range(5):
		await physics_frame
	Input.action_release("attack")
	Input.action_release("move_right")
	check(game.player.position == player_position and target.health == health_before and game.training.step == step_before, "Pausa com áudio deve congelar treino")
	game.toggle_pause()
	check(paused and not game.audio_settings_open, "Esc no áudio deve voltar ao treino pausado")
	game.toggle_pause()
	check(not paused and game.state == game.State.TRAINING, "Retomar deve restaurar treino")
	game.player.facing = Vector2.RIGHT
	game.player.attack_cooldown = 0
	game.player.attack()
	check(target.health == health_before - 10, "Régua deve aplicar dano real ao alvo")
	game.player.attack()
	check(target.health == health_before - 10, "Treino deve respeitar recarga da régua")
	check(target.position == target_position and game.player.health == 100, "Alvo nunca deve perseguir ou ferir jogador")
	Input.action_press("attack")
	for frame in range(70):
		await physics_frame
		if game.training.step == game.training.Step.EXIT:
			break
	Input.action_release("attack")
	check(game.training.step == game.training.Step.EXIT and game.room.enemies.is_empty() and game.room.door_open, "Três golpes devem liberar porta sem premiar")
	game.advance_room()
	check(game.state == game.State.TRAINING, "Só pode concluir treino perto da porta")
	game.player.position = game.room.DOOR
	game.advance_room()
	check(game.state == game.State.TRAINING_COMPLETE and not game.player.active and not game.training.running, "E na porta deve concluir treino e bloquear ataques")
	check(game.run_report.elapsed_seconds == 0 and game.run_report.answers.is_empty() and game.run_report.snapshot().is_empty(), "Treino não deve gerar relatório ou consumir tempo da partida")
	check(game.questions.last_seen == history and game.questions.offered.is_empty() and game.questions.pending_reward.is_empty(), "Treino deve preservar histórico sem oferecer questões ou bônus")
	check(game.player.damage == 10 and game.player.max_health == 100 and game.player.speed_bonus_percent == 0, "Treino não deve conceder atributos")
	game.ui.content.get_child(3).pressed.emit() # Jogar expedição pela conclusão.
	check(game.state == game.State.QUESTION and game.room.route_index == 1 and game.room_index == 0 and not game.training.visible, "Conclusão deve iniciar rota real do começo")
	check(game.questions.offered.size() == 2 and game.questions.offered[0].difficulty == "basic" and game.player.health == 100, "Partida após treino deve iniciar fácil e com vida normal")
	game.show_menu()
	game.start_training()
	await move_until_step(game, game.training.Step.SPRINT)
	game.toggle_pause()
	game.start_training()
	check(not paused and game.training.step == game.training.Step.MOVE and game.training.sprint_distance == 0, "Recomeçar pela pausa deve limpar treino")
	game.show_menu()
	check(not game.training.running and not game.training.visible and game.room.enemies.is_empty(), "Voltar ao menu deve limpar treino")
	game.start_training()
	await move_until_step(game, game.training.Step.SPRINT)
	await move_until_step(game, game.training.Step.ATTACK, true)
	game.toggle_pause()
	game.show_menu()
	check(game.room.enemies.is_empty() and not game.room.combat_active and not paused, "Abandonar treino com alvo deve limpar todos os estados")
	await process_frame
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	print("TRAINING TESTS: %d failure(s)" % failures)
	quit(1 if failures else 0)
