extends "res://tests/capture_preview.gd"

func capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://builds/previews")
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.start_run(1)
	for index in range(4):
		if index == 0:
			var longest: Dictionary = game.questions.bank[0]
			for question in game.questions.bank:
				if (question.prompt + question.explanation).length() > (longest.prompt + longest.explanation).length():
					longest = question
			game.questions.offered[0] = longest.duplicate(true)
		game.choose_question(0)
		game.answer_question((int(game.questions.selected.correct) + 1) % 4 if index == 0 else game.questions.selected.correct)
		game.begin_combat()
		for enemy in game.room.enemies.duplicate():
			enemy.take_damage(1000)
		await process_frame
		if index < 3:
			game.player.position = game.room.DOOR
			game.advance_room()
	await save_preview("e1-victory")
	game.save_run_report("res://builds/preview-reports")
	await save_preview("e1-saved")
	DirAccess.remove_absolute(game.run_report.saved_path)
	DirAccess.remove_absolute("res://builds/preview-reports")
	game.show_answer_review(0)
	await save_preview("e1-review")
	game.ui.content.get_child(game.ui.content.get_child_count() - 1).grab_focus()
	await save_preview("e1-review-buttons")
	root.size = Vector2i(1280, 720)
	await save_preview("e1-review-resized")
	root.size = Vector2i(960, 540)
	game.start_run()
	game.choose_question(0)
	game.answer_question(game.questions.selected.correct)
	game.begin_combat()
	game.player.take_damage(1000)
	await save_preview("e1-defeat")
	game.show_answer_review(0)
	await save_preview("e1-cancelled")
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	quit()
