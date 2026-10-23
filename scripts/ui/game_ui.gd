extends CanvasLayer

var header: Label
var footer: Label
var overlay: ColorRect
var content: VBoxContainer
var scroll: ScrollContainer
var health_bar: ProgressBar
var health_label: Label
var health_notice: Label
var health_status: Label
var health_fill: StyleBoxFlat
var last_health: int = -1
var last_max_health: int = -1
var notice_time: float = 0.0

func _ready() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_create_health_display(root)
	header = Label.new()
	header.position = Vector2(425, 13)
	header.add_theme_font_size_override("font_size", 18)
	root.add_child(header)
	footer = Label.new()
	root.add_child(footer)
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_left = 24
	footer.offset_top = -38
	footer.add_theme_font_size_override("font_size", 16)
	overlay = ColorRect.new()
	overlay.color = Color(0.03, 0.06, 0.10, 0.94)
	root.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	overlay.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 90
	panel.offset_right = -90
	panel.offset_top = 55
	panel.offset_bottom = -55
	var style := StyleBoxFlat.new()
	style.bg_color = Color("203147")
	style.set_corner_radius_all(16)
	style.content_margin_left = 26
	style.content_margin_right = 26
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", style)
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	panel.add_child(scroll)
	content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	scroll.add_child(content)

func _create_health_display(root: Control) -> void:
	health_bar = ProgressBar.new()
	health_bar.position = Vector2(24, 12)
	health_bar.size = Vector2(220, 26)
	health_bar.show_percentage = false
	health_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background := StyleBoxFlat.new()
	background.bg_color = Color("24354a")
	background.set_corner_radius_all(6)
	background.set_border_width_all(1)
	background.border_color = Color("7087a3")
	health_bar.add_theme_stylebox_override("background", background)
	health_fill = StyleBoxFlat.new()
	health_fill.bg_color = Color("54d6a8")
	health_fill.set_corner_radius_all(6)
	health_bar.add_theme_stylebox_override("fill", health_fill)
	root.add_child(health_bar)
	health_label = Label.new()
	health_bar.add_child(health_label)
	health_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	health_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	health_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	health_label.add_theme_font_size_override("font_size", 16)
	health_label.add_theme_color_override("font_outline_color", Color("111d2a"))
	health_label.add_theme_constant_override("outline_size", 4)
	health_notice = Label.new()
	health_notice.position = Vector2(260, 5)
	health_notice.add_theme_font_size_override("font_size", 15)
	root.add_child(health_notice)
	health_status = Label.new()
	health_status.position = Vector2(260, 24)
	health_status.add_theme_font_size_override("font_size", 13)
	health_status.add_theme_color_override("font_color", Color("ffb3bd"))
	root.add_child(health_status)

func reset_health_feedback() -> void:
	last_health = -1
	last_max_health = -1
	notice_time = 0.0
	health_notice.text = ""

func _process(delta: float) -> void:
	if get_tree().paused:
		return
	if notice_time > 0.0:
		notice_time = maxf(0.0, notice_time - delta)
		if notice_time == 0.0:
			health_notice.text = ""

func update_health(health: int, maximum: int) -> void:
	if health == last_health and maximum == last_max_health:
		return
	health_bar.max_value = maximum
	health_bar.value = health
	health_label.text = "VIDA %d/%d" % [health, maximum]
	var low_health := health > 0 and float(health) / maximum <= 0.25
	health_status.text = "SEM VIDA" if health == 0 else ("VIDA BAIXA" if low_health else "")
	health_fill.bg_color = Color("df7c8b") if low_health or health == 0 else Color("54d6a8")
	if last_health >= 0:
		var difference := health - last_health
		if difference != 0:
			health_notice.text = "%+d vida" % difference
			health_notice.add_theme_color_override("font_color", Color("ffb3bd") if difference < 0 else Color("54d6a8"))
			notice_time = 1.5
		elif maximum != last_max_health:
			health_notice.text = "%+d vida máxima" % (maximum - last_max_health)
			health_notice.add_theme_color_override("font_color", Color("ffdb80"))
			notice_time = 1.5
	last_health = health
	last_max_health = maximum

func update_hud(health: int, maximum: int, damage: int, room_number: int, enemies: int, message: String) -> void:
	update_health(health, maximum)
	header.text = "Régua %d   |   Sala %d/4   |   Inimigos %d" % [damage, room_number, enemies]
	footer.text = message

func show_panel(title: String, description: String, choices: Array) -> void:
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()
	overlay.show()
	scroll.scroll_vertical = 0
	var heading := Label.new()
	heading.text = title
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	heading.add_theme_font_size_override("font_size", 30)
	content.add_child(heading)
	var text := Label.new()
	text.text = description
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.add_theme_font_size_override("font_size", 18)
	content.add_child(text)
	var first_button: Button
	for choice in choices:
		var button := Button.new()
		button.text = choice["text"]
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size.y = 48
		button.add_theme_font_size_override("font_size", 18)
		button.pressed.connect(choice["action"])
		content.add_child(button)
		if first_button == null:
			first_button = button
	if first_button != null:
		first_button.grab_focus()
	# Começa pelo título; navegação posterior por Tab acompanha o foco.
	scroll.set_deferred("scroll_vertical", 0)

func hide_panel() -> void:
	overlay.hide()
