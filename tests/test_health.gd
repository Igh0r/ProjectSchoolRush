extends SceneTree

var failures: int = 0

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
	check(game.ui.health_bar.value == 100 and game.ui.health_bar.max_value == 100, "Barra inicial deve estar cheia")
	check(game.ui.health_notice.text.is_empty(), "Início não deve mostrar uma cura")
	game.player.take_damage(75)
	check(game.ui.health_bar.value == 25 and game.ui.health_label.text == "VIDA 25/100", "Dano deve atualizar barra e número pelo sinal")
	check(game.ui.health_notice.text == "-75 vida" and game.ui.health_status.text == "VIDA BAIXA", "Dano e vida baixa precisam de indicação textual")
	game.player.heal(1)
	check(game.ui.health_status.text.is_empty(), "Acima de 25% deve retirar aviso")
	game.player.increase_max_health(20)
	check(game.player.health == 26 and game.player.max_health == 120, "Aumentar o limite não deve curar automaticamente")
	check(game.ui.health_bar.max_value == 120 and game.ui.health_status.text == "VIDA BAIXA", "Percentual de vida baixa deve usar limite novo")
	check(game.ui.health_notice.text == "+20 vida máxima", "Alteração do limite deve ter feedback próprio")
	game.player.heal(20)
	check(game.player.health == 46 and game.ui.health_notice.text == "+20 vida", "Cura deve informar aumento real")
	check(game.ui.health_status.text.is_empty(), "Cura deve remover alerta quando sair da faixa baixa")
	game.player.heal(1000)
	check(game.player.health == 120 and game.ui.health_bar.value == 120, "Cura deve respeitar o limite aumentado")
	check(game.ui.health_notice.text == "+74 vida", "Cura limitada deve informar apenas vida recuperada")
	game.player.take_damage(-10)
	game.player.heal(-10)
	game.player.increase_max_health(-10)
	check(game.player.health == 120 and game.player.max_health == 120, "Valores negativos não devem alterar atributos")
	game.toggle_pause()
	var saved_time: float = game.ui.notice_time
	game.ui._process(2.0)
	check(game.ui.notice_time == saved_time, "Aviso deve congelar durante pausa")
	game.toggle_pause()
	game.ui._process(2.0)
	check(game.ui.health_notice.text.is_empty(), "Aviso temporário deve desaparecer")
	game.player.invulnerability = 0.0
	game.player.take_damage(1000)
	check(game.ui.health_bar.value == 0 and game.ui.health_status.text == "SEM VIDA", "Dano letal deve esvaziar barra")
	game.player.heal(20)
	check(game.player.health == 0, "Cura não deve ressuscitar jogador derrotado")
	game.start_run()
	check(game.player.health == 100 and game.player.max_health == 100, "Reinício deve restaurar vida e limite base")
	check(game.ui.health_bar.value == 100 and game.ui.health_bar.max_value == 100, "Reinício deve restaurar barra inteira")
	check(game.ui.health_notice.text.is_empty() and game.ui.health_status.text.is_empty(), "Reinício deve limpar alertas sem cura falsa")
	await process_frame # Processa os inícios de áudio agendados neste frame antes da limpeza.
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("HEALTH TESTS: %d failure(s)" % failures)
	quit(1 if failures else 0)
