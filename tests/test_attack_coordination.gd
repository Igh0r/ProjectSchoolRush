extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func run_tests() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.start_run(1)
	game.choose_question(0)
	game.answer_question(0)
	game.begin_combat()
	game.room.clear_enemies()
	game.room.set_combat(true)
	game.player.position = Vector2(400, 210)
	var cloud = game.room.spawn_enemy("cloud", Vector2(600, 210), game.player)
	var scientist = game.room.spawn_enemy("scientist", Vector2(600, 300), game.player)
	var guard = game.room.spawn_enemy("centurion", Vector2(480, 210), game.player)
	for enemy in game.room.enemies:
		enemy.set_physics_process(false)
	cloud._physics_process(0.01)
	scientist._physics_process(0.01)
	guard._physics_process(0.01)
	check(game.room.attack_reservations.size() == 2, "No máximo dois ataques especiais concorrentes")
	check(guard.phase == guard.Phase.APPROACH and game.room.attack_queue.has(guard), "Terceiro atacante aguarda sem anunciar dano")
	cloud._physics_process(0.81)
	for shot in game.room.projectiles:
		shot.set_physics_process(false)
	guard._physics_process(0.01)
	check(guard.phase == guard.Phase.APPROACH, "Tiro em voo ainda ocupa uma vaga")
	game.room.clear_projectiles(cloud)
	guard._physics_process(0.01)
	check(guard.phase == guard.Phase.WARNING, "Aguardar libera ataque depois de sumir o perigo")
	check(game.room.attack_reservations.size() == 2, "Nova reserva preserva limite")
	scientist._physics_process(1.01)
	cloud.phase = cloud.Phase.APPROACH
	cloud._physics_process(0.01)
	check(cloud.phase == cloud.Phase.APPROACH, "Mistura ainda ocupa vaga durante a fase ativa")
	var mixture = game.room.mixtures[0]
	mixture.set_physics_process(false)
	var timer: float = guard.phase_time
	var reservations: Dictionary = game.room.attack_reservations.duplicate()
	guard.set_physics_process(true)
	game.toggle_pause()
	for frame in range(4):
		await physics_frame
	check(guard.phase_time == timer and game.room.attack_reservations == reservations, "Pausa congela ataque e reservas")
	check(not game.room.request_attack(cloud), "Nenhuma vaga é concedida na pausa")
	game.toggle_pause()
	guard.set_physics_process(false)
	scientist.take_damage(1000)
	cloud._physics_process(0.01)
	check(cloud.phase == cloud.Phase.WARNING and game.room.mixtures.is_empty(), "Morte libera vaga e cancela área")
	game.room.set_combat(false)
	check(game.room.attack_queue.is_empty() and game.room.attack_reservations.is_empty(), "Fim do combate limpa fila e reservas")
	game.start_run()
	check(game.room.attack_queue.is_empty() and game.room.attack_reservations.is_empty(), "Reinício não conserva coordenação")
	# Chefe: golpe anunciado, direção fixa, acerto único, esquiva e recuperação.
	game.room_index = 3
	game.choose_question(0)
	game.answer_question(0)
	game.begin_combat()
	var boss = game.room.enemies[0]
	boss.set_physics_process(false)
	game.player.position = Vector2(510, 210)
	boss.phase = boss.Phase.APPROACH
	boss.phase_time = 1.6
	boss._physics_process(0.01)
	check(boss.phase == boss.Phase.SWEEP_WARNING, "Chefe anuncia varredura ao se aproximar")
	var direction: Vector2 = boss.charge_direction
	var before: int = game.player.health
	boss._physics_process(0.45)
	check(game.player.health == before, "Varredura não causa dano no aviso")
	game.player.position = Vector2(690, 210)
	boss._physics_process(0.46)
	check(boss.charge_direction == direction and game.player.health == before, "Sair do setor evita varredura de mira fixa")
	boss._physics_process(0.21)
	check(boss.phase == boss.Phase.RECOVERY, "Varredura deve abrir recuperação")
	boss._physics_process(1.21)
	check(boss.phase == boss.Phase.WARNING, "Após varredura, chefe anuncia investida")
	boss.phase = boss.Phase.APPROACH
	boss.phase_time = 1.6
	game.player.position = Vector2(510, 210)
	game.player.invulnerability = 0.0
	boss._physics_process(0.01)
	boss._physics_process(0.91)
	check(game.player.health == before - 20, "Varredura atinge jogador que permanece no setor")
	game.player.invulnerability = 0.0
	boss._physics_process(0.05)
	check(game.player.health == before - 20, "Varredura só causa um acerto")
	boss._physics_process(0.2)
	boss.next_sweep = true
	boss._physics_process(1.21)
	game.player.position = Vector2(100, 100)
	boss._physics_process(1.61)
	check(boss.phase == boss.Phase.WARNING, "Aproximação tem prazo e volta a uma investida anunciada")
	boss.take_damage(1000)
	check(game.room.attack_reservations.is_empty(), "Morte do chefe libera reserva")
	await process_frame
	# Simulação real da sala mista: a fila precisa atender todos, não só respeitar o teto.
	game.start_run(1)
	game.choose_question(0)
	game.answer_question(0)
	game.begin_combat()
	game.room.clear_enemies()
	game.room.set_combat(true)
	game.player.position = Vector2(400, 210)
	game.player.invulnerability = 30.0
	cloud = game.room.spawn_enemy("cloud", Vector2(600, 210), game.player)
	scientist = game.room.spawn_enemy("scientist", Vector2(600, 300), game.player)
	guard = game.room.spawn_enemy("centurion", Vector2(480, 210), game.player)
	var attacks := {"cloud": 0, "scientist": 0, "guard": 0}
	cloud.shot_requested.connect(func(_source, _origin, _direction): attacks.cloud += 1)
	scientist.mixture_requested.connect(func(_source, _point): attacks.scientist += 1)
	var previous_guard_phase: int = -1
	for frame in range(600):
		await physics_frame
		if guard.phase == guard.Phase.STRIKE and previous_guard_phase != guard.Phase.STRIKE:
			attacks.guard += 1
		previous_guard_phase = guard.phase
		check(game.room.attack_reservations.size() <= 2, "Limite deve valer durante a simulação real")
	for kind in attacks:
		check(attacks[kind] >= 2, "Fila não pode impedir ataques recorrentes: " + kind)
	game.show_menu()
	check(game.room.attack_queue.is_empty() and game.room.attack_reservations.is_empty(), "Menu encerra a coordenação em andamento")
	await process_frame
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	print("ATTACK COORDINATION TESTS: %d failure(s)" % failures)
	quit(1 if failures else 0)
