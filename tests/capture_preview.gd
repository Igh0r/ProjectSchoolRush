extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func save_preview(filename: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png("res://builds/previews/" + filename + ".png")
	if result != OK:
		push_error("Falha ao salvar captura: " + filename)

func start_with_question(game: Node, question_id: String) -> int:
	for seed_value in range(200):
		game.questions.rng.seed = seed_value
		game.start_run()
		for i in range(game.questions.offered.size()):
			if game.questions.offered[i].id == question_id:
				return i
	push_error("Questão não encontrada para captura: " + question_id)
	return -1

func capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://builds/previews")
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await save_preview("01-menu")
	game.start_run()
	await save_preview("02-questions")
	game.choose_question(0)
	await save_preview("03-answer")
	game.answer_question(game.questions.selected.correct)
	await save_preview("04-feedback")
	game.begin_combat()
	await save_preview("05-combat")
	for enemy in game.room.enemies.duplicate():
		enemy.take_damage(1000)
	await save_preview("06-cleared")
	game.start_run()
	game.room_index = 3
	game.choose_question(0)
	game.answer_question(game.questions.selected.correct)
	game.begin_combat()
	await save_preview("07-boss")
	game.toggle_pause()
	await save_preview("08-pause")
	game.toggle_pause()
	game.room.enemies[0].take_damage(1000)
	await save_preview("09-victory")
	root.size = Vector2i(1280, 720)
	game.start_run()
	await save_preview("10-resized")
	root.size = Vector2i(960, 540)
	game.choose_question(0)
	game.answer_question(0)
	game.begin_combat()
	game.room.set_combat(false)
	game.player.take_damage(10)
	await save_preview("11-health-damage")
	game.player.invulnerability = 0.0
	game.player.take_damage(65)
	await save_preview("12-health-low")
	game.player.increase_max_health(20)
	await save_preview("13-health-maximum")
	game.player.heal(20)
	await save_preview("14-health-heal")
	root.size = Vector2i(1280, 720)
	await save_preview("15-health-resized")
	root.size = Vector2i(960, 540)
	for question_id in ["mat3", "his1", "cie1", "cie5", "por2"]:
		var index := start_with_question(game, question_id)
		if index < 0:
			game.queue_free()
			quit(1)
			return
		await save_preview("16-" + question_id + "-choice")
		game.choose_question(index)
		await save_preview("17-" + question_id + "-answer")
		game.answer_question(int(game.questions.selected.correct))
		await save_preview("18-" + question_id + "-feedback")
		game.begin_combat()
		for enemy in game.room.enemies.duplicate():
			enemy.take_damage(1000)
		await save_preview("19-" + question_id + "-reward")
		game.toggle_pause()
		await save_preview("20-" + question_id + "-stats")
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	quit()
