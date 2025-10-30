extends Control

var built: bool = false;
var running: bool = false;
var sped_up: bool = false;
var current_offset: float = 0;
var last_context: String = "";

@export var credits: AdieuResource;
@export var autoplay: bool = true;

@export_custom(PROPERTY_HINT_NONE, "suffix:px/s") var scroll_speed: float = 12;
@export var speed_up_multiplier: float = 3.0;
@export var speed_up_action: InputEventAction;

@export_subgroup("Margins")
@export var include_top_y_in_start: bool = false;
@export var credits_x_margins: Vector2i = Vector2i(128, 128);
@export var credits_y_margins: Vector2i = Vector2i(256, 256);

@export_subgroup("Styling")
@export var header_font: Font;
@export var context_font: Font;
@export var text_font: Font;
@export var default_styling: Dictionary[String, String] = {};
@export var hide_repeat_contexts: bool = true;

@export_subgroup("Components")
@export var margin_container: MarginContainer;
@export var panel_container: PanelContainer;
@export var list_container: VBoxContainer;

func _ready() -> void:
	_apply_margins();
	_apply_initial_offset();

	if autoplay:
		run();

func _process(delta: float) -> void:
	sped_up = Input.is_action_pressed(speed_up_action.action);

	if running:
		_scroll_step(delta);

func build():
	if credits == null:
		push_error("[ADIEU] Failed to build credits, no resource was present.");
		return;

	for section in credits.data["Sections"]:
		_build_section(section, list_container);

	built = true;

func run():
	if credits == null:
		push_error("[ADIEU] Failed to play credits, no resource was present.");
		return;

	if !built:
		build();

	running = true;

func stop():
	running = false;

func _scroll_step(delta: float):
	var base_offset = _get_base_offset();
	var diff = (scroll_speed * delta * _get_speed_mult());

	panel_container.global_position.y -= diff;
	current_offset -= diff;

	if panel_container.global_position.y - (base_offset + current_offset) > 12:
		panel_container.global_position.y = (base_offset + current_offset);

func _get_speed_mult() -> float:
	return speed_up_multiplier if sped_up else 1.0;

# --- Initialization ---

func _apply_margins():
	margin_container.add_theme_constant_override("margin_left",   credits_x_margins.x);
	margin_container.add_theme_constant_override("margin_right",  credits_x_margins.y);
	margin_container.add_theme_constant_override("margin_top",    credits_y_margins.x);
	margin_container.add_theme_constant_override("margin_bottom", credits_y_margins.y);

func _apply_initial_offset():
	var viewport_height = get_viewport_rect().size.y;
	panel_container.global_position.y = viewport_height;

func _get_base_offset() -> float:
	var total_h = get_viewport_rect().size.y;
	if include_top_y_in_start:
		total_h -= credits_y_margins.x;

	return total_h;

# --- Prop Builders ---

func _build_section(section: Dictionary, list_parent: VBoxContainer):
	var dup_default_styling = default_styling.duplicate();
	var section_style = section["Styling"].duplicate();

	section_style.merge(dup_default_styling, false);
	last_context = ""; # Clear last context for each section to prevent false positives

	var section_container = VBoxContainer.new();
	section_container.name = section["Title"];

	if AdieuStyling.should_display_header(section_style):
		section_container.add_child(_build_section_header(section["Title"], section_style));

	for line in section["Lines"]:
		section_container.add_child(_build_section_line(line, section_style));

	for style_key in section_style.keys():
		match style_key:
			AdieuStyling.KEYS.MIN_HEIGHT: AdieuStyling.apply_min_height(section_style[style_key], section_container);

	list_parent.add_child(section_container);

func _build_section_header(header: String, styling: Dictionary) -> Control:
	var label = Label.new();
	var label_settings = LabelSettings.new();

	label.text = header;
	label.label_settings = label_settings;

	if header_font != null:
		label.label_settings.font = header_font;

	for style_key in styling.keys():
		match style_key:
			AdieuStyling.KEYS.HEADER_ALIGN: AdieuStyling.apply_text_align(styling[style_key], label);
			AdieuStyling.KEYS.HEADER_SIZE: AdieuStyling.apply_text_size(styling[style_key], label);
			AdieuStyling.KEYS.HEADER_COLOR: AdieuStyling.apply_text_color(styling[style_key], label);

	return label;

func _build_section_line(line: Dictionary, styling: Dictionary) -> Control:
	var content_container = HBoxContainer.new();
	content_container.alignment = BoxContainer.ALIGNMENT_CENTER;

	content_container.add_child(_build_section_line_text(line, styling));
	if AdieuStyling.should_display_context(styling):
		content_container.add_child(_build_section_line_context(line, styling));

	for style_key in styling.keys():
		match style_key:
			AdieuStyling.KEYS.GAP: AdieuStyling.apply_gap(styling[style_key], content_container);

	return content_container;

func _build_section_line_text(line: Dictionary, styling: Dictionary) -> Control:
	var label = Label.new();
	var label_settings = LabelSettings.new();

	label.text = line["Text"];

	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;
	label.size_flags_vertical   = Control.SIZE_FILL;
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL;

	label.label_settings = label_settings;

	if text_font != null:
		label.label_settings.font = text_font;

	for style_key in styling.keys():
		match style_key:
			AdieuStyling.KEYS.TEXT_ALIGN: AdieuStyling.apply_text_align(styling[style_key], label);
			AdieuStyling.KEYS.TEXT_SIZE: AdieuStyling.apply_text_size(styling[style_key], label);
			AdieuStyling.KEYS.TEXT_COLOR: AdieuStyling.apply_text_color(styling[style_key], label);

	return label;

func _build_section_line_context(line: Dictionary, styling: Dictionary) -> Control:
	var label = Label.new();
	var label_settings = LabelSettings.new();

	var context = line.get("Context", "");

	if context == last_context && hide_repeat_contexts:
		label.text = "";
	else:
		label.text = context;
		last_context = context;

	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;
	label.size_flags_vertical   = Control.SIZE_FILL;
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL;
	label.label_settings = label_settings;

	if context_font != null:
		label.label_settings.font = context_font;

	for style_key in styling.keys():
		match style_key:
			AdieuStyling.KEYS.CONTEXT_ALIGN: AdieuStyling.apply_text_align(styling[style_key], label);
			AdieuStyling.KEYS.CONTEXT_SIZE: AdieuStyling.apply_text_size(styling[style_key], label);
			AdieuStyling.KEYS.CONTEXT_COLOR: AdieuStyling.apply_text_color(styling[style_key], label);

	return label;
