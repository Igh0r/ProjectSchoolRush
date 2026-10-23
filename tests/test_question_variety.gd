extends SceneTree

const QUESTIONS = preload("res://scripts/systems/question_manager.gd")
var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	for seed_value in range(100):
		var manager = QUESTIONS.new()
		manager.rng.seed = seed_value
		var original: Array = manager.bank.duplicate(true)
		var seen: Dictionary = {}
		var shuffled := false
		for run_index in range(12):
			manager.reset()
			var run_ids: Dictionary = {}
			var subjects: Dictionary = {}
			for room_index in range(4):
				var offers = manager.offer()
				check(offers.size() == 2 and offers[0].subject != offers[1].subject, "Duas matérias por oferta")
				for question in offers:
					check(not run_ids.has(question.id), "Nunca repetir ID na mesma partida")
					run_ids[question.id] = true
					subjects[question.subject] = subjects.get(question.subject, 0) + 1
					if run_index < 10:
						check(not seen.has(question.id), "Usar as oitenta inéditas antes de repetir na sessão")
					seen[question.id] = true
					var source: Dictionary = original.filter(func(q): return q.id == question.id)[0]
					check(question.options[int(question.correct)] == source.options[int(source.correct)], "Embaralhamento deve preservar o gabarito")
					shuffled = shuffled or question.options != source.options
				manager.choose(0)
				var answer: int = int(manager.selected.correct)
				var right := (room_index % 2 == 0)
				check(manager.answer(answer if right else (answer + 1) % 4) == right, "Resposta remapeada deve aceitar acerto e rejeitar erro")
				check(manager.consume_reward() == (manager.selected.subject if right else ""), "Embaralhamento preserva bônus")
				if room_index == 1:
					check(subjects.size() == 4, "Todas as matérias nas duas primeiras salas")
			for count in subjects.values():
				check(count == 2, "Duas aparições de cada matéria por partida")
		check(seen.size() == 80 and shuffled, "Banco inteiro acessível com alternativas variadas")
		check(manager.bank == original, "Sorteio não pode mutar o catálogo")
	# Preferências e degradação controlada: tema e dificuldade nunca bloqueiam.
	var manager = QUESTIONS.new()
	manager.reset()
	var pool: Array[Dictionary] = []
	for question in manager.bank:
		if question.subject == "math":
			pool.append(question)
	check(manager._pick_question(pool).difficulty == "basic", "Primeira sala prefere revisão quando há inéditas")
	manager.offer_number = 3
	check(manager._pick_question(pool).difficulty == "challenge", "Última sala prefere desafio quando há inéditas")
	var sample: Dictionary = pool[0]
	manager.last_topic.math = sample.topic
	check(manager._pick_question(pool).topic != sample.topic, "Evitar tema da última oferta da matéria")
	for i in range(pool.size()):
		manager.last_seen[pool[i].id] = i + 1
	check(manager._pick_question(pool).id == pool[0].id, "Após esgotar inéditas, reutilizar a menos recente")
	pool.resize(1)
	check(manager._pick_question(pool).id == sample.id, "Sem tema ou dificuldade ideal, usar questão disponível")
	var fresh = QUESTIONS.new()
	check(fresh.last_seen.is_empty(), "Nova sessão inicia histórico vazio")
	print("QUESTION VARIETY TESTS: %d failure(s)" % failures)
	quit(1 if failures else 0)
