extends "res://tests/capture_preview.gd"

func capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://builds/previews")
	var game = load("res://main.tscn").instantiate()
	game.audio_settings_path = "res://builds/preview-audio-unsaved.cfg"
	root.add_child(game)
	await save_preview("e4-menu")
	game.show_audio_settings()
	await save_preview("e4-audio")
	game.ui.content.get_child(game.ui.content.get_child_count() - 1).get_child(2).grab_focus()
	await save_preview("e4-audio-buttons")
	game.close_audio_settings()
	game.start_run()
	game.choose_question(0)
	game.answer_question(game.questions.selected.correct)
	game.begin_combat()
	game.toggle_pause()
	await save_preview("e4-pause")
	game.show_audio_settings()
	game.ui.content.get_child(2).get_child(1).value = 40
	game.ui.content.get_child(3).get_child(1).value = 65
	game.ui.content.get_child(4).button_pressed = true
	await save_preview("e4-adjusted")
	game.show_audio_settings("Não foi possível salvar. Os ajustes continuam nesta sessão; tente novamente.")
	await save_preview("e4-save-error")
	root.size = Vector2i(1280, 720)
	await save_preview("e4-resized")
	game.close_audio_settings()
	game.show_menu()
	await process_frame
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	quit()
