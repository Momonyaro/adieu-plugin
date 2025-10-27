extends Control

var built: bool = false;

@export var credits: AdieuResource;
@export var autoplay: bool = true;

@export_subgroup("Margins")
@export var include_top_y_in_start: bool = false;
@export var credits_x_margins: Vector2i = Vector2i(128, 128);
@export var credits_y_margins: Vector2i = Vector2i(256, 256);

@export_subgroup("Styling")
@export var header_font: Font;
@export var context_font: Font;
@export var text_font: Font;
@export var default_styling: Dictionary[String, String] = {};
@export var skip_repeat_contexts: bool = true;

@export_subgroup("Components")
@export var margin_container: MarginContainer;
@export var panel_container: PanelContainer;
@export var list_container: VBoxContainer;

func _ready() -> void:
	_apply_margins();
	#_apply_initial_offset();

	if autoplay:
		run();

func run():
	if credits == null:
		push_error("[ADIEU] Failed to play credits, no resource was present.");
		return;

	if !built:
		build();

	# Do shit!
	pass;

func build():
	if credits == null:
		push_error("[ADIEU] Failed to build credits, no resource was present.");
		return;

	for section in credits.data["Sections"]:
		_build_section(section, list_container);

# --- Initialization ---

func _apply_margins():
	margin_container.add_theme_constant_override("margin_left",   credits_x_margins.x);
	margin_container.add_theme_constant_override("margin_right",  credits_x_margins.y);
	margin_container.add_theme_constant_override("margin_top",    credits_y_margins.x);
	margin_container.add_theme_constant_override("margin_bottom", credits_y_margins.y);

func _apply_initial_offset():
	var viewport_height = get_viewport_rect().size.y;

	panel_container.global_position.y += viewport_height;
	if include_top_y_in_start:
		panel_container.global_position.y -= credits_y_margins.x;

# --- Prop Builders ---

func _build_section(section: Dictionary, list_parent: VBoxContainer):
	var dup_default_styling = default_styling.duplicate();
	var section_style = section["Styling"].duplicate();

	section_style.merge(dup_default_styling);

	var section_container = VBoxContainer.new();
	if AdieuStyling.should_display_header(section_style):
		section_container.add_child(_build_section_header(section["Title"], section_style));

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
		pass;

	return label;
