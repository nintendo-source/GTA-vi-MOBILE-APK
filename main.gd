extends Control

const YOUTUBE_CHANNEL_URL := "https://www.youtube.com/@Glaxiblade"

@onready var screen1: Control = $Screen1_Splash
@onready var screen2: Control = $Screen2_Narration
@onready var screen3: Control = $Screen3_Navigation
@onready var screen4: Control = $Screen4_TextSize
@onready var screen5: Control = $Screen5_HDR
@onready var screen6: Control = $Screen6_Finish
@onready var video_player: VideoStreamPlayer = $VideoPlayer
@onready var start_button: Button = $Screen1_Splash/Button

var boot_video: VideoStream = preload("res://assets/boot_intro.ogv")
var screens: Array[Control] = []
var current_index: int = 0
var confirmed_summary: bool = false

var setup_data: Array[Dictionary] = [
	{
		"title": "SCREEN NARRATION",
		"options": ["Off (Default)", "On"],
		"descriptions": [
			"Screen narration is turned off.",
			"Reads on-screen text and menu options aloud."
		],
		"selected": 0
	},
	{
		"title": "MENU NAVIGATION",
		"options": ["Touch & Swipe (Default)", "On-Screen D-Pad"],
		"descriptions": [
			"Tap options directly or swipe to cycle settings.",
			"Use virtual directional buttons to navigate menus."
		],
		"selected": 0
	},
	{
		"title": "UI TEXT SIZE",
		"options": ["Small (Default)", "Medium", "Large", "Extra Large"],
		"descriptions": [
			"Text and icons are balanced in size.",
			"Slightly larger text for comfortable handheld reading.",
			"Large high-visibility menu text and icons.",
			"Maximum text scaling for accessibility."
		],
		"selected": 0
	},
	{
		"title": "DISPLAY & HDR",
		"options": ["Standard SDR (Default)", "HDR Vivid", "HDR Cinema"],
		"descriptions": [
			"Standard dynamic range optimized for all mobile displays.",
			"Boosted contrast and highlights for OLED screens.",
			"Balanced HDR tone mapping for darker environments."
		],
		"selected": 0
	},
	{
		"title": "CONFIRM SETTINGS",
		"options": ["Review & Apply"],
		"descriptions": [
			"Tap CONFIRM to apply your setup preferences."
		],
		"selected": 0
	}
]

func _ready() -> void:
	_setup_purple_background()

	if screen2.has_node("Button"):
		screen2.get_node("Button").visible = false

	screens = [screen2, screen3, screen4, screen5, screen6]
	for i in range(screens.size()):
		if i < screens.size() - 1:
			_build_setup_screen(screens[i], i)
		else:
			_build_confirm_and_subscribe_screen(screens[i], i)

	_show_only(screen1)
	video_player.visible = false
	video_player.loop = false
	video_player.stream = boot_video

	start_button.pressed.connect(_on_start_pressed)
	video_player.finished.connect(_on_boot_video_finished)

func _setup_purple_background() -> void:
	if not has_node("SetupBG"):
		return

	var bg: TextureRect = $SetupBG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var grad := Gradient.new()
	grad.colors = PackedColorArray([
		Color.html("#2a1e47"),
		Color.html("#4c3575"),
		Color.html("#6f4da3")
	])
	grad.offsets = PackedFloat32Array([0.0, 0.55, 1.0])

	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill_from = Vector2(0.5, 0.0)
	tex.fill_to = Vector2(0.5, 1.0)

	bg.texture = tex

func _show_only(target: Control) -> void:
	screen1.visible = (target == screen1)
	for s in screens:
		s.visible = (s == target)

func _on_start_pressed() -> void:
	_show_only(null)
	video_player.visible = true
	video_player.stream = boot_video
	video_player.play()

func _on_boot_video_finished() -> void:
	video_player.stop()
	video_player.visible = false
	confirmed_summary = false
	current_index = 0
	_show_only(screens[current_index])

func _make_pill_style(bg_color: Color, border_color: Color, radius: int = 14) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg_color
	sb.border_color = border_color
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	return sb

func _style_nav_button(btn: Button, primary: bool = false) -> void:
	btn.focus_mode = Control.FOCUS_NONE
	if primary:
		btn.add_theme_stylebox_override("normal", _make_pill_style(Color(1, 1, 1, 0.94), Color(1, 1, 1, 1.0), 12))
		btn.add_theme_stylebox_override("hover", _make_pill_style(Color(1, 1, 1, 1.0), Color(0.92, 0.85, 1.0, 1.0), 12))
		btn.add_theme_stylebox_override("pressed", _make_pill_style(Color(0.84, 0.76, 0.98, 1.0), Color(1, 1, 1, 1.0), 12))
		btn.add_theme_color_override("font_color", Color.html("#24183d"))
		btn.add_theme_color_override("font_hover_color", Color.html("#1c1130"))
		btn.add_theme_color_override("font_pressed_color", Color.html("#1c1130"))
	else:
		btn.add_theme_stylebox_override("normal", _make_pill_style(Color(1, 1, 1, 0.14), Color(1, 1, 1, 0.42), 12))
		btn.add_theme_stylebox_override("hover", _make_pill_style(Color(1, 1, 1, 0.24), Color(1, 1, 1, 0.72), 12))
		btn.add_theme_stylebox_override("pressed", _make_pill_style(Color(1, 1, 1, 0.34), Color(1, 1, 1, 0.9), 12))
		btn.add_theme_color_override("font_color", Color(0.97, 0.96, 1.0, 1.0))
		btn.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1.0))
		btn.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 1.0))

func _style_arrow_button(btn: Button) -> void:
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(74, 74)
	btn.add_theme_font_size_override("font_size", 32)
	btn.add_theme_stylebox_override("normal", _make_pill_style(Color(1, 1, 1, 0.12), Color(1, 1, 1, 0.36), 37))
	btn.add_theme_stylebox_override("hover", _make_pill_style(Color(1, 1, 1, 0.24), Color(1, 1, 1, 0.75), 37))
	btn.add_theme_stylebox_override("pressed", _make_pill_style(Color(1, 1, 1, 0.38), Color(1, 1, 1, 1.0), 37))
	btn.add_theme_color_override("font_color", Color(1, 1, 1, 0.96))

func _build_setup_screen(root: Control, idx: int) -> void:
	var data: Dictionary = setup_data[idx]

	var center := VBoxContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.set_anchors_preset(Control.PRESET_CENTER)
	center.offset_left = -420
	center.offset_right = 420
	center.offset_top = -140
	center.offset_bottom = 140
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 20)
	root.add_child(center)

	var title_lbl := Label.new()
	title_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_lbl.text = data["title"]
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 54)
	title_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.98))
	center.add_child(title_lbl)

	var pill_panel := PanelContainer.new()
	pill_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill_panel.add_theme_stylebox_override("panel", _make_pill_style(Color(0.08, 0.05, 0.16, 0.42), Color(1, 1, 1, 0.22), 18))
	center.add_child(pill_panel)

	var selector_row := HBoxContainer.new()
	selector_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selector_row.alignment = BoxContainer.ALIGNMENT_CENTER
	selector_row.add_theme_constant_override("separation", 28)
	pill_panel.add_child(selector_row)

	var left_btn := Button.new()
	left_btn.text = "<"
	_style_arrow_button(left_btn)
	selector_row.add_child(left_btn)

	var option_lbl := Label.new()
	option_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	option_lbl.custom_minimum_size = Vector2(360, 56)
	option_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	option_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	option_lbl.add_theme_font_size_override("font_size", 32)
	option_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.98))
	selector_row.add_child(option_lbl)

	var right_btn := Button.new()
	right_btn.text = ">"
	_style_arrow_button(right_btn)
	selector_row.add_child(right_btn)

	var sep := ColorRect.new()
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sep.custom_minimum_size = Vector2(560, 2)
	sep.color = Color(1, 1, 1, 0.24)
	center.add_child(sep)

	var dots_lbl := Label.new()
	dots_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dots_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dots_lbl.add_theme_font_size_override("font_size", 22)
	dots_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.92))
	center.add_child(dots_lbl)

	var bottom_line := ColorRect.new()
	bottom_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom_line.color = Color(1, 1, 1, 0.25)
	bottom_line.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_line.offset_top = -124
	bottom_line.offset_bottom = -122
	root.add_child(bottom_line)

	var desc_lbl := Label.new()
	desc_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desc_lbl.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	desc_lbl.offset_left = 70
	desc_lbl.offset_top = -98
	desc_lbl.offset_right = 1120
	desc_lbl.offset_bottom = -34
	desc_lbl.add_theme_font_size_override("font_size", 26)
	desc_lbl.add_theme_color_override("font_color", Color(0.95, 0.94, 0.99, 0.95))
	root.add_child(desc_lbl)

	var nav_row := HBoxContainer.new()
	nav_row.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	nav_row.offset_left = -480
	nav_row.offset_top = -102
	nav_row.offset_right = -60
	nav_row.offset_bottom = -32
	nav_row.alignment = BoxContainer.ALIGNMENT_END
	nav_row.add_theme_constant_override("separation", 20)
	root.add_child(nav_row)

	var continue_btn := Button.new()
	continue_btn.text = "CONTINUE"
	continue_btn.custom_minimum_size = Vector2(190, 58)
	continue_btn.add_theme_font_size_override("font_size", 23)
	_style_nav_button(continue_btn, true)
	nav_row.add_child(continue_btn)

	var back_btn := Button.new()
	back_btn.text = "BACK"
	back_btn.custom_minimum_size = Vector2(140, 58)
	back_btn.add_theme_font_size_override("font_size", 23)
	back_btn.visible = (idx > 0)
	_style_nav_button(back_btn, false)
	nav_row.add_child(back_btn)

	var refresh := func() -> void:
		var opts: Array = data["options"]
		var descs: Array = data["descriptions"]
		var sel: int = data["selected"]
		option_lbl.text = opts[sel]
		desc_lbl.text = descs[sel]

		left_btn.visible = (opts.size() > 1)
		right_btn.visible = (opts.size() > 1)

		var dots := ""
		for d in range(opts.size()):
			dots += ("●  " if d == sel else "○  ")
		dots_lbl.text = dots.strip_edges()

	refresh.call()

	left_btn.pressed.connect(func() -> void:
		var count: int = data["options"].size()
		data["selected"] = (data["selected"] - 1 + count) % count
		refresh.call()
	)

	right_btn.pressed.connect(func() -> void:
		var count: int = data["options"].size()
		data["selected"] = (data["selected"] + 1) % count
		refresh.call()
	)

	continue_btn.pressed.connect(func() -> void:
		if current_index < screens.size() - 1:
			current_index += 1
			_show_only(screens[current_index])
	)

	back_btn.pressed.connect(func() -> void:
		if current_index > 0:
			current_index -= 1
			_show_only(screens[current_index])
	)

func _build_confirm_and_subscribe_screen(root: Control, idx: int) -> void:
	var confirm_view := VBoxContainer.new()
	confirm_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	confirm_view.set_anchors_preset(Control.PRESET_CENTER)
	confirm_view.offset_left = -460
	confirm_view.offset_right = 460
	confirm_view.offset_top = -190
	confirm_view.offset_bottom = 140
	confirm_view.alignment = BoxContainer.ALIGNMENT_CENTER
	confirm_view.add_theme_constant_override("separation", 20)
	root.add_child(confirm_view)

	var confirm_title := Label.new()
	confirm_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	confirm_title.text = "CONFIRM SETTINGS"
	confirm_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	confirm_title.add_theme_font_size_override("font_size", 54)
	confirm_title.add_theme_color_override("font_color", Color(1, 1, 1, 0.98))
	confirm_view.add_child(confirm_title)

	var summary_panel := PanelContainer.new()
	summary_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	summary_panel.add_theme_stylebox_override("panel", _make_pill_style(Color(0.08, 0.05, 0.16, 0.48), Color(1, 1, 1, 0.24), 18))
	confirm_view.add_child(summary_panel)

	var summary_lbl := Label.new()
	summary_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	summary_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary_lbl.add_theme_font_size_override("font_size", 24)
	summary_lbl.add_theme_color_override("font_color", Color(0.96, 0.95, 1.0, 0.96))
	summary_panel.add_child(summary_lbl)

	var confirm_btn := Button.new()
	confirm_btn.text = "CONFIRM"
	confirm_btn.custom_minimum_size = Vector2(220, 62)
	confirm_btn.add_theme_font_size_override("font_size", 25)
	_style_nav_button(confirm_btn, true)
	confirm_view.add_child(confirm_btn)

	var sub_view := VBoxContainer.new()
	sub_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sub_view.visible = false
	sub_view.set_anchors_preset(Control.PRESET_CENTER)
	sub_view.offset_left = -460
	sub_view.offset_right = 460
	sub_view.offset_top = -170
	sub_view.offset_bottom = 120
	sub_view.alignment = BoxContainer.ALIGNMENT_CENTER
	sub_view.add_theme_constant_override("separation", 18)
	root.add_child(sub_view)

	var sub_title := Label.new()
	sub_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sub_title.text = "SETTINGS CONFIRMED"
	sub_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_title.add_theme_font_size_override("font_size", 54)
	sub_title.add_theme_color_override("font_color", Color(1, 1, 1, 0.98))
	sub_view.add_child(sub_title)

	var sub_msg := Label.new()
	sub_msg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sub_msg.text = "Your preferences are saved."
	sub_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_msg.add_theme_font_size_override("font_size", 26)
	sub_msg.add_theme_color_override("font_color", Color(0.94, 0.93, 0.99, 0.95))
	sub_view.add_child(sub_msg)

	var bottom_line := ColorRect.new()
	bottom_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom_line.color = Color(1, 1, 1, 0.25)
	bottom_line.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_line.offset_top = -124
	bottom_line.offset_bottom = -122
	root.add_child(bottom_line)

	var desc_lbl := Label.new()
	desc_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desc_lbl.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	desc_lbl.offset_left = 70
	desc_lbl.offset_top = -98
	desc_lbl.offset_right = 680
	desc_lbl.offset_bottom = -34
	desc_lbl.add_theme_font_size_override("font_size", 24)
	desc_lbl.add_theme_color_override("font_color", Color(0.95, 0.94, 0.99, 0.95))
	root.add_child(desc_lbl)

	var yt_btn := Button.new()
	yt_btn.focus_mode = Control.FOCUS_NONE
	yt_btn.visible = false
	yt_btn.custom_minimum_size = Vector2(390, 66)
	yt_btn.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	yt_btn.offset_left = -195
	yt_btn.offset_right = 195
	yt_btn.offset_top = -104
	yt_btn.offset_bottom = -30
	yt_btn.add_theme_stylebox_override("normal", _make_pill_style(Color.html("#161024"), Color.html("#ff0033"), 14))
	yt_btn.add_theme_stylebox_override("hover", _make_pill_style(Color.html("#251638"), Color.html("#ff335c"), 14))
	yt_btn.add_theme_stylebox_override("pressed", _make_pill_style(Color.html("#38182a"), Color.html("#ff0033"), 14))
	root.add_child(yt_btn)

	var yt_row := HBoxContainer.new()
	yt_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	yt_row.set_anchors_preset(Control.PRESET_FULL_RECT)
	yt_row.alignment = BoxContainer.ALIGNMENT_CENTER
	yt_row.add_theme_constant_override("separation", 14)
	yt_btn.add_child(yt_row)

	var badge := Control.new()
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.custom_minimum_size = Vector2(44, 30)
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	yt_row.add_child(badge)

	var badge_bg := ColorRect.new()
	badge_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge_bg.position = Vector2(0, 0)
	badge_bg.size = Vector2(44, 30)
	badge_bg.color = Color.html("#FF0000")
	badge.add_child(badge_bg)

	var play_tri := Polygon2D.new()
	play_tri.polygon = PackedVector2Array([
		Vector2(17, 8),
		Vector2(31, 15),
		Vector2(17, 22)
	])
	play_tri.color = Color.WHITE
	badge.add_child(play_tri)

	var yt_label := Label.new()
	yt_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	yt_label.text = "SUBSCRIBE TO Glaxiblade"
	yt_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	yt_label.add_theme_font_size_override("font_size", 22)
	yt_label.add_theme_color_override("font_color", Color.WHITE)
	yt_row.add_child(yt_label)

	var back_btn := Button.new()
	back_btn.text = "BACK"
	back_btn.custom_minimum_size = Vector2(140, 58)
	back_btn.add_theme_font_size_override("font_size", 23)
	back_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	back_btn.offset_left = -200
	back_btn.offset_top = -102
	back_btn.offset_right = -60
	back_btn.offset_bottom = -32
	_style_nav_button(back_btn, false)
	root.add_child(back_btn)

	var refresh_view := func() -> void:
		var lines: PackedStringArray = []
		for i in range(4):
			var item: Dictionary = setup_data[i]
			lines.append("%s: %s" % [item["title"], item["options"][item["selected"]]])
		summary_lbl.text = "\n".join(lines)

		confirm_view.visible = not confirmed_summary
		sub_view.visible = confirmed_summary
		yt_btn.visible = confirmed_summary

		if confirmed_summary:
			desc_lbl.text = "Opening YouTube..."
		else:
			desc_lbl.text = "Review your selections and tap CONFIRM."

	root.visibility_changed.connect(func() -> void:
		if root.visible:
			refresh_view.call()
	)

	confirm_btn.pressed.connect(func() -> void:
		confirmed_summary = true
		refresh_view.call()
	)

	yt_btn.pressed.connect(func() -> void:
		OS.shell_open(YOUTUBE_CHANNEL_URL)
	)

	back_btn.pressed.connect(func() -> void:
		if confirmed_summary:
			confirmed_summary = false
			refresh_view.call()
		elif current_index > 0:
			current_index -= 1
			_show_only(screens[current_index])
	)
