extends CanvasLayer

var header: Label
var footer: Label
var overlay: ColorRect
var content: VBoxContainer
var scroll: ScrollContainer

func _ready() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	header = Label.new()
	header.position = Vector2(24, 12)
	header.add_theme_font_size_override("font_size", 19)
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
	panel.add_child(scroll)
	content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	scroll.add_child(content)

func update_hud(health: int, damage: int, room_number: int, enemies: int, message: String) -> void:
	header.text = "SCHOOL RUSH   •   Vida %d/100   |   Régua %d   |   Sala %d/4   |   Inimigos %d" % [health, damage, room_number, enemies]
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

func hide_panel() -> void:
	overlay.hide()
