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
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	quit()
