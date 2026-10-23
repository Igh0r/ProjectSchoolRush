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
	game.start_run()
	game.choose_question(0)
	game.answer_question(0)
	game.begin_combat()
	game.room.clear_enemies()
	game.room.set_combat(true)
	game.player.position = Vector2(100, 210)
	game.player.active = false
	var a = game.room.spawn_enemy("dice", Vector2(500, 210), game.player)
	var b = game.room.spawn_enemy("dice", Vector2(500, 210), game.player)
	for frame in range(45):
		await physics_frame
	check(a.position.distance_to(b.position) > 25.0, "Dados sobrepostos devem se separar no movimento real")
	check(a.position.x < 500 and b.position.x < 500, "Separação deve preservar aproximação")
	a.position = Vector2(30, 30)
	b.position = Vector2(30, 30)
	game.player.position = Vector2(-100, -100)
	for frame in range(30):
		await physics_frame
	check(a.position.x >= 27 and a.position.y >= 27 and b.position.x >= 27 and b.position.y >= 27, "Separação não deve atravessar paredes")
	game.room.clear_enemies()
	game.room.set_combat(true)
	game.player.position = Vector2(400, 210)
	for kind in ["cloud", "scientist"]:
		game.room.set_combat(true)
		var enemy = game.room.spawn_enemy(kind, Vector2(520, 210), game.player)
		enemy.set_physics_process(false)
		await physics_frame
		enemy.phase = enemy.Phase.RECOVERY
		enemy.phase_time = 0.5
		var before: Vector2 = enemy.position
		enemy._physics_process(0.1)
		check(enemy.position.distance_to(game.player.position) > before.distance_to(game.player.position), "Inimigo próximo deve reposicionar entre ataques: " + kind)
		check(enemy.velocity.length() <= 45.01, "Reposicionamento deve ser alcançável pelo jogador")
		enemy.phase = enemy.Phase.WARNING
		enemy.phase_time = 0.7
		before = enemy.position
		enemy._physics_process(0.1)
		check(enemy.position == before, "Aviso não pode mover origem do ataque: " + kind)
		enemy.take_damage(1000)
	game.room.set_combat(true)
	var cactus = game.room.spawn_enemy("cactus", Vector2(600, 210), game.player)
	cactus.set_physics_process(false)
	var first_spread: float = cactus.spread
	cactus._physics_process(0.96)
	game.room.clear_projectiles()
	cactus._physics_process(1.61)
	check(cactus.phase == cactus.Phase.WARNING and cactus.spread > first_spread, "Cacto deve alternar abertura antes de anunciar")
	var announced: float = cactus.spread
	var locked: Vector2 = cactus.shot_direction
	game.player.position = Vector2(400, 300)
	cactus._physics_process(0.96)
	check(game.room.projectiles.size() == 3, "Novo padrão preserva três espinhos")
	check(game.room.projectiles[0].direction.is_equal_approx(locked.rotated(-announced)), "Leque deve corresponder às linhas anunciadas")
	game.room.clear_projectiles()
	cactus._physics_process(1.61)
	check(is_equal_approx(cactus.spread, first_spread), "Cacto deve retornar ao padrão estreito")
	game.room.clear_enemies()
	await process_frame
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	print("ENEMY MOVEMENT TESTS: %d failure(s)" % failures)
	quit(1 if failures else 0)
