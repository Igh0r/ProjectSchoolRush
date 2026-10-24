extends "res://tests/capture_preview.gd"

func capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://builds/previews")
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	for resolution in [Vector2i(960, 540), Vector2i(1280, 720)]:
		root.size = resolution
		game.start_run(1)
		for index in range(4):
			await save_preview("e2-%d-room-%d" % [resolution.x, index + 1])
			game.choose_question(0)
			game.answer_question((int(game.questions.selected.correct) + 1) % 4 if index == 1 else game.questions.selected.correct)
			game.begin_combat()
			for enemy in game.room.enemies.duplicate():
				enemy.take_damage(1000)
			await process_frame
			if index < 3:
				game.player.position = game.room.DOOR
				game.advance_room()
		game.show_answer_review(0)
		await save_preview("e3-%d-levels" % resolution.x)
	game.start_run()
	game.choose_question(0)
	game.answer_question(game.questions.selected.correct)
	game.begin_combat()
	game.player.take_damage(1000)
	game.show_answer_review(0)
	await save_preview("e3-unanswered-levels")
	await process_frame
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	quit()
