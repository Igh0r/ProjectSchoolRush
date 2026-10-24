extends RefCounted

const CATALOG = preload("res://scripts/systems/curriculum_catalog.gd")
const ROOM_DIFFICULTIES = ["basic", "intermediate", "intermediate", "challenge"]
var bank: Array[Dictionary] = []
var subjects: Dictionary = {}
var audience: String = ""
var validation_errors := PackedStringArray()
var remaining: Array[Dictionary] = []
var offered: Array[Dictionary] = []
var selected: Dictionary = {}
var answered: bool = false
var pending_reward: String = ""
var exposure: Dictionary = {}
var last_seen: Dictionary = {}
var last_topic: Dictionary = {}
var topic_exposure: Dictionary = {}
var offer_number: int = 0
var session_order: int = 0
var rng := RandomNumberGenerator.new()

func _init() -> void:
	var catalog = CATALOG.new()
	validation_errors = catalog.errors
	rng.randomize()
	if not validation_errors.is_empty():
		return
	audience = catalog.data.audience
	bank.assign(catalog.data.questions)
	for subject in catalog.data.subjects:
		subjects[subject.id] = subject

func reset() -> void:
	remaining = bank.duplicate(true)
	offered.clear()
	selected = {}
	answered = false
	pending_reward = ""
	exposure.clear()
	topic_exposure.clear()
	offer_number = 0
	for subject_id in subjects:
		exposure[subject_id] = 0

func offer() -> Array[Dictionary]:
	offered.clear()
	selected = {}
	answered = false
	pending_reward = ""
	var available: Array[String] = []
	for question in remaining:
		if not available.has(question.subject):
			available.append(question.subject)
	if available.size() < 2:
		return offered
	# Prioriza matérias menos apresentadas; sorteia apenas os empates.
	for slot in range(2):
		var least_seen: int = 2147483647
		var candidates: Array[String] = []
		for subject_id in available:
			var count: int = exposure[subject_id]
			if count < least_seen:
				least_seen = count
				candidates.clear()
			if count == least_seen:
				candidates.append(subject_id)
		var chosen: String = candidates[rng.randi_range(0, candidates.size() - 1)]
		available.erase(chosen)
		exposure[chosen] += 1
		var pool: Array[Dictionary] = []
		for question in remaining:
			if question.subject == chosen:
				pool.append(question)
		var picked := _pick_question(pool)
		remaining.erase(picked)
		session_order += 1
		last_seen[picked.id] = session_order
		last_topic[chosen] = picked.topic
		var topic_key: String = chosen + ":" + picked.topic
		topic_exposure[topic_key] = topic_exposure.get(topic_key, 0) + 1
		offered.append(_shuffle_options(picked))
	offer_number += 1
	return offered

func _pick_question(pool: Array[Dictionary]) -> Dictionary:
	# Nível da sala antes da novidade. Fallback mais próximo, preferindo o mais fácil no empate.
	var desired: int = CATALOG.DIFFICULTIES.find(room_difficulty(offer_number))
	var best_level_score: int = 2147483647
	var eligible: Array[Dictionary] = []
	for question in pool:
		var level: int = CATALOG.DIFFICULTIES.find(question.difficulty)
		var score: int = absi(level - desired) * 10 + level
		if score < best_level_score:
			best_level_score = score
			eligible.clear()
		if score == best_level_score:
			eligible.append(question)
	# Dentro do nível: inéditas, depois menos recentes. Nunca repõe a partida.
	var oldest: int = 2147483647
	for question in eligible:
		oldest = mini(oldest, int(last_seen.get(question.id, 0)))
	var candidates: Array[Dictionary] = []
	var best_score: int = 2147483647
	for question in eligible:
		if int(last_seen.get(question.id, 0)) != oldest:
			continue
		var topic_key: String = question.subject + ":" + question.topic
		var repeated_topic: int = int(topic_exposure.get(topic_key, 0)) + int(last_topic.get(question.subject, "") == question.topic)
		var score: int = repeated_topic
		if score < best_score:
			best_score = score
			candidates.clear()
		if score == best_score:
			candidates.append(question)
	return candidates[rng.randi_range(0, candidates.size() - 1)]

func _shuffle_options(question: Dictionary) -> Dictionary:
	var copy := question.duplicate(true)
	var answer_text: String = copy.options[int(copy.correct)]
	for i in range(copy.options.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var temporary: String = copy.options[i]
		copy.options[i] = copy.options[j]
		copy.options[j] = temporary
	copy.correct = copy.options.find(answer_text)
	return copy

func room_difficulty(index: int) -> String:
	return ROOM_DIFFICULTIES[clampi(index, 0, ROOM_DIFFICULTIES.size() - 1)]

func difficulty_name(difficulty: String) -> String:
	return {"basic": "Fácil", "intermediate": "Médio", "challenge": "Difícil"}.get(difficulty, "")

func choose(index: int) -> bool:
	if not selected.is_empty() or index < 0 or index >= offered.size():
		return false
	selected = offered[index]
	return true

func answer(index: int) -> bool:
	if selected.is_empty() or answered or index < 0 or index > 3:
		return false
	answered = true
	var correct: bool = index == int(selected.correct)
	pending_reward = selected.subject if correct else ""
	return correct

func consume_reward() -> String:
	var reward := pending_reward
	pending_reward = ""
	return reward

func subject_name(subject_id: String) -> String:
	return subjects.get(subject_id, {}).get("name", "")

func reward_config(subject_id: String) -> Dictionary:
	return subjects.get(subject_id, {}).get("reward", {}).duplicate(true)

func reward_description(subject_id: String) -> String:
	var reward := reward_config(subject_id)
	match reward.get("type", ""):
		"damage":
			return "+%d de dano da régua" % int(reward.amount)
		"heal":
			return "+%d de vida (até a vida máxima)" % int(reward.amount)
		"max_health":
			return "+%d vida máxima e +%d vida" % [int(reward.amount), int(reward.heal)]
		"speed":
			return "+%s%% velocidade (limite +%s%%)" % [String.num(reward.amount, 2), String.num(reward.cap, 2)]
	return ""
