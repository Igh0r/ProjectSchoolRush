extends RefCounted

const CATALOG = preload("res://scripts/systems/curriculum_catalog.gd")
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
		var picked: Dictionary = pool[rng.randi_range(0, pool.size() - 1)]
		offered.append(picked)
		remaining.erase(picked)
	return offered

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
