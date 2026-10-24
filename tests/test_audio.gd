extends SceneTree

const PREFERENCES = preload("res://scripts/systems/audio_preferences.gd")
var failures: int = 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func run_tests() -> void:
	var directory := "res://builds/audio-tests-%d" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(directory)
	var path := directory.path_join("audio.cfg")
	var preferences = PREFERENCES.new()
	check(preferences.load_from(path) == ERR_FILE_NOT_FOUND and preferences.music_percent == 100.0, "Sem arquivo deve usar padrão")
	var config := ConfigFile.new()
	config.set_value("audio", "music", "inválido")
	config.set_value("audio", "effects", -50)
	config.set_value("audio", "effects_muted", "true")
	check(config.save(path) == OK, "Preparar preferências inválidas")
	check(preferences.load_from(path) == OK and preferences.music_percent == 100 and preferences.effects_percent == 0 and not preferences.effects_muted, "Tipos inválidos devem usar padrão e valores respeitar limites")
	config.set_value("audio", "music", 150)
	config.set_value("audio", "effects", NAN)
	config.save(path)
	preferences.load_from(path)
	check(preferences.music_percent == 100 and preferences.effects_percent == 100, "Valores excessivos e não finitos devem ser seguros")
	preferences.music_percent = 35
	preferences.effects_percent = 60
	preferences.effects_muted = true
	check(preferences.save_to(path) == OK, "Preferências devem salvar")
	var game = load("res://main.tscn").instantiate()
	game.audio_settings_path = path
	root.add_child(game)
	check(is_equal_approx(game.music.volume_linear, db_to_linear(-8.0) * 0.35), "Início deve aplicar música salva")
	check(game.sounds.muted and game.sounds.volume_percent == 60, "Início deve aplicar efeitos salvos")
	game.show_audio_settings()
	check(game.state == game.State.MENU and not paused and game.audio_settings_open, "Áudio no menu não inicia partida")
	# Usa controles reais para verificar sinais, valores independentes e labels.
	var music_slider: HSlider = game.ui.content.get_child(2).get_child(1)
	var effects_slider: HSlider = game.ui.content.get_child(3).get_child(1)
	music_slider.value = 0
	effects_slider.value = 25
	check(game.music.volume_linear == 0 and game.sounds.volume_percent == 25, "Sliders devem ajustar canais independentes")
	check(game.ui.content.get_child(2).get_child(0).text == "Música: 0%" and game.ui.content.get_child(3).get_child(0).text == "Efeitos: 25%", "Labels devem acompanhar cada slider")
	game.ui.content.get_child(4).button_pressed = false
	game.sounds.play_cue("correct")
	check(game.sounds.channels[0].playing and is_equal_approx(game.sounds.channels[0].volume_linear, db_to_linear(-20.0) * 0.25), "Volume de efeitos deve ser aplicado ao som")
	game.set_effects_volume(0)
	game.sounds.play_cue("correct")
	check(game.sounds.channels.all(func(channel): return not channel.playing), "Volume zero deve interromper e impedir efeitos")
	game.toggle_pause() # Esc fecha áudio sem iniciar/pausar partida.
	check(not game.audio_settings_open and game.state == game.State.MENU, "Esc no áudio do menu deve voltar ao menu")
	var loaded = PREFERENCES.new()
	loaded.load_from(path)
	check(loaded.music_percent == 35 and loaded.effects_muted, "Voltar sem salvar não pode alterar arquivo")
	game.start_run(1)
	check(game.music.playing and game.music.volume_linear == 0, "Música silenciosa deve continuar a faixa sem resetar preferência")
	game.choose_question(0)
	game.answer_question(game.questions.selected.correct)
	game.begin_combat()
	game.show_audio_settings()
	check(not game.audio_settings_open, "Áudio só abre no menu ou na pausa")
	game.toggle_pause()
	var enemy = game.room.enemies[0]
	var location: Vector2 = enemy.position
	var elapsed: float = game.run_report.elapsed_seconds
	game.show_audio_settings()
	game.set_music_volume(50)
	game.set_effects_volume(75)
	var mute_event := InputEventAction.new()
	mute_event.action = "mute"
	mute_event.pressed = true
	game._unhandled_input(mute_event)
	check(game.sounds.muted and game.ui.content.get_child(4).button_pressed, "Atalho M deve sincronizar o controle sem mudar a música")
	check(is_equal_approx(game.music.volume_linear, db_to_linear(-8.0) * 0.5), "M não pode silenciar música")
	await process_frame
	await physics_frame
	check(paused and enemy.position == location and game.run_report.elapsed_seconds == elapsed, "Ajustar áudio na pausa não pode retomar combate ou tempo")
	game.audio_settings_path = directory.path_join("missing/audio.cfg")
	game.save_audio_settings()
	check(game.audio_settings_open and paused and game.ui.content.get_child(1).text.contains("Não foi possível salvar"), "Falha ao salvar deve informar e manter pausa")
	game.audio_settings_path = path
	game.save_audio_settings()
	check(not game.audio_settings_open and game.state == game.State.PAUSED and paused, "Salvar deve voltar à pausa sem retomar combate")
	loaded.load_from(path)
	check(loaded.music_percent == 50 and loaded.effects_percent == 75 and loaded.effects_muted, "Salvar deve persistir valores e silêncio")
	game.show_audio_settings()
	game.reset_audio_settings()
	check(game.audio_preferences.music_percent == 100 and game.audio_preferences.effects_percent == 100 and not game.sounds.muted, "Restaurar deve aplicar volumes originais e remover silêncio")
	game.close_audio_settings()
	game.toggle_pause()
	check(not paused and game.state == game.State.COMBAT, "Retomar após configurar deve restaurar combate")
	game.start_run()
	check(game.audio_preferences.music_percent == 100 and not game.sounds.muted, "Reinício deve preservar ajustes da sessão")
	game.show_menu()
	game.show_audio_settings()
	game.save_audio_settings()
	loaded.load_from(path)
	check(loaded.music_percent == 100 and not loaded.effects_muted, "Padrão também deve poder ser salvo")
	await process_frame
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	DirAccess.remove_absolute(path)
	DirAccess.remove_absolute(directory)
	print("AUDIO TESTS: %d failure(s)" % failures)
	quit(1 if failures else 0)
