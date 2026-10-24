extends SceneTree

var failures: int = 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func travel(player: Node, actions: Array, frames: int) -> float:
	player.position = Vector2(400, 210)
	for action in actions:
		Input.action_press(action)
	for i in range(frames):
		await physics_frame
	for action in actions:
		Input.action_release(action)
	return player.position.distance_to(Vector2(400, 210))

func run_tests() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.start_run()
	game.choose_question(0)
	game.answer_question(0)
	game.begin_combat()
	game.room.set_combat(false)
	await physics_frame
	var walk: float = await travel(game.player, ["move_right"], 12)
	var sprint: float = await travel(game.player, ["move_right", "sprint"], 12)
	var diagonal: float = await travel(game.player, ["move_right", "move_down"], 12)
	check(absf(sprint / walk - 1.4) < 0.05, "Corrida deve aumentar velocidade em 40%")
	check(absf(diagonal / walk - 1.0) < 0.05, "Diagonal não pode aumentar velocidade")
	game.player.apply_reward(game.questions.reward_config("portuguese"))
	var boosted: float = await travel(game.player, ["move_right"], 12)
	check(absf(boosted / walk - 1.05) < 0.05, "Bônus de Português deve aumentar o deslocamento real")
	await travel(game.player, ["move_right", "sprint"], 90)
	check(game.player.position.x <= 774.0, "Parede direita deve segurar jogador correndo")
	await travel(game.player, ["move_up", "sprint"], 45)
	check(game.player.position.y >= 26.0, "Parede superior deve segurar jogador correndo")
	game.player.take_damage(10)
	var saved_health: int = game.player.health
	game.toggle_pause()
	var saved_time: float = game.player.invulnerability
	var saved_position: Vector2 = game.player.position
	Input.action_press("move_right")
	for i in range(5):
		await physics_frame
	Input.action_release("move_right")
	check(game.player.position == saved_position and game.player.invulnerability == saved_time, "Pausa deve congelar jogador e invulnerabilidade")
	game.toggle_pause()
	game.player.active = false
	game.player.take_damage(10)
	check(game.player.health == saved_health, "Jogador inativo não deve receber dano")
	# Encerra os playbacks antes de liberar a cena; a thread de áudio termina de soltar os streams.
	game.music.stop()
	game.music.stream = null
	game.sounds.set_preferences(0.0, true)
	await process_frame
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	print("MOVEMENT TESTS: %d failure(s)" % failures)
	quit(1 if failures else 0)
