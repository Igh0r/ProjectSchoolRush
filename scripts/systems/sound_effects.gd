extends Node

var muted: bool = false
var clips: Dictionary = {}
var channels: Array[AudioStreamPlayer] = []
var next_channel: int = 0

func _exit_tree() -> void:
	for channel in channels:
		channel.stop()
		channel.stream = null
	clips.clear()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	var tones := {"attack": Vector2(360, 0.06), "hurt": Vector2(120, 0.16), "correct": Vector2(740, 0.16), "wrong": Vector2(180, 0.14), "clear": Vector2(880, 0.22)}
	for cue in tones:
		clips[cue] = _tone(tones[cue].x, tones[cue].y)
	for i in range(4):
		var channel := AudioStreamPlayer.new()
		channel.volume_db = -20.0
		add_child(channel)
		channels.append(channel)

func play_cue(cue: String) -> void:
	if muted or not clips.has(cue):
		return
	var channel := channels[next_channel]
	next_channel = (next_channel + 1) % channels.size()
	channel.stream = clips[cue]
	channel.play()

func toggle_mute() -> void:
	muted = not muted
	if muted:
		for channel in channels:
			channel.stop()

func _tone(frequency: float, duration: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var samples := int(duration * sample_rate)
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var envelope := sin(PI * float(i) / samples)
		var value := int(sin(TAU * frequency * float(i) / sample_rate) * envelope * 16000.0)
		data.encode_s16(i * 2, value)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream
