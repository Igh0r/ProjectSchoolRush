extends SceneTree

var failures: int = 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func enter_combat(game: Node) -> void:
	game.start_run()
	game.choose_question(0)
	game.answer_question((game.questions.selected.correct + 1) % 4)
	game.begin_combat()

func run_tests() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	enter_combat(game)
	check(game.room.enemies.size() == 2, "A primeira sala deve ter dois inimigos")
	var front = game.room.enemies[0]
	var back = game.room.enemies[1]
	game.player.position = Vector2(400, 210)
	game.player.facing = Vector2.RIGHT
	front.position = Vector2(440, 210)
	back.position = Vector2(360, 210)
	game.player.attack()
	check(front.health == 20 and back.health == 30, "Golpe deve atingir só o cone frontal")
	game.player.attack()
	check(front.health == 20, "Cooldown deve impedir dano repetido")
	game.player.take_damage(10)
	game.player.take_damage(10)
	check(game.player.health == 90, "Invulnerabilidade deve impedir dano duplicado")
	game.player.invulnerability = 0.0
	game.player.take_damage(100)
	check(game.state == game.State.DEFEAT, "Morte deve encerrar a partida")
	check(not front.active, "Derrota deve parar os inimigos")
	for i in range(3):
		enter_combat(game)
		await process_frame
		check(game.room.enemies.size() == 2 and game.player.health == 100, "Reinício deve restaurar vida e inimigos")
		check(game.player.damage == 10, "Reinício deve restaurar dano")
		for enemy in game.room.enemies.duplicate():
			enemy.take_damage(100)
		await process_frame
		check(game.state == game.State.CLEARED, "Eliminar todos deve concluir a sala")
	game.queue_free()
	await process_frame
	print("COMBAT TESTS: %d failure(s)" % failures)
	quit(1 if failures else 0)
