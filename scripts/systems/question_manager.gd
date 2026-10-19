extends RefCounted

# Banco provisório: revisão pedagógica pela equipe antes do playtest público.
const BANK: Array[Dictionary] = [
	{"id": "mat1", "subject": "Matemática", "prompt": "Quanto é 7 × 8?", "options": ["54", "56", "64", "48"], "correct": 1, "explanation": "7 × 8 = 56."},
	{"id": "mat2", "subject": "Matemática", "prompt": "Qual é a metade de 90?", "options": ["30", "40", "45", "50"], "correct": 2, "explanation": "Dividir 90 por 2 resulta em 45."},
	{"id": "mat3", "subject": "Matemática", "prompt": "Qual é o perímetro de um quadrado de lado 5 cm?", "options": ["10 cm", "25 cm", "15 cm", "20 cm"], "correct": 3, "explanation": "O perímetro soma os quatro lados: 4 × 5 = 20 cm."},
	{"id": "mat4", "subject": "Matemática", "prompt": "Quanto é 25% de 80?", "options": ["20", "25", "40", "60"], "correct": 0, "explanation": "25% equivale a um quarto. 80 dividido por 4 é 20."},
	{"id": "mat5", "subject": "Matemática", "prompt": "Qual número completa 3, 6, 9, 12, ...?", "options": ["13", "14", "15", "18"], "correct": 2, "explanation": "A sequência aumenta de 3 em 3. Depois de 12 vem 15."},
	{"id": "his1", "subject": "História", "prompt": "Em que ano foi proclamada a República no Brasil?", "options": ["1822", "1888", "1889", "1930"], "correct": 2, "explanation": "A Proclamação da República ocorreu em 15 de novembro de 1889."},
	{"id": "his2", "subject": "História", "prompt": "Qual civilização construiu as pirâmides de Gizé?", "options": ["Romana", "Egípcia", "Inca", "Grega"], "correct": 1, "explanation": "As pirâmides de Gizé foram construídas no Egito Antigo."},
	{"id": "his3", "subject": "História", "prompt": "A Revolução Francesa começou em qual ano?", "options": ["1500", "1789", "1822", "1914"], "correct": 1, "explanation": "1789 marca o início da Revolução Francesa, incluindo a queda da Bastilha."},
	{"id": "his4", "subject": "História", "prompt": "Qual lei aboliu a escravidão no Brasil em 1888?", "options": ["Lei Áurea", "Lei de Terras", "Lei do Ventre Livre", "Lei dos Sexagenários"], "correct": 0, "explanation": "A Lei Áurea foi assinada em 13 de maio de 1888."},
	{"id": "his5", "subject": "História", "prompt": "Napoleão Bonaparte foi imperador de qual país?", "options": ["Portugal", "Espanha", "Itália", "França"], "correct": 3, "explanation": "Napoleão Bonaparte foi imperador dos franceses."},
]
var remaining: Array[Dictionary] = []
var offered: Array[Dictionary] = []
var selected: Dictionary = {}
var answered: bool = false
var pending_reward: String = ""

func reset() -> void:
	remaining = BANK.duplicate(true)
	remaining.shuffle()
	offered.clear()
	selected = {}
	answered = false
	pending_reward = ""

func offer() -> Array[Dictionary]:
	offered.clear()
	selected = {}
	answered = false
	pending_reward = ""
	for subject in ["Matemática", "História"]:
		for question in remaining:
			if question.subject == subject:
				offered.append(question)
				remaining.erase(question)
				break
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
	var correct: bool = index == selected.correct
	pending_reward = selected.subject if correct else ""
	return correct

func consume_reward() -> String:
	var reward := pending_reward
	pending_reward = ""
	return reward

func reward_description(subject: String) -> String:
	return "+2 de dano da régua" if subject == "Matemática" else "+20 de vida (máximo 100)"
