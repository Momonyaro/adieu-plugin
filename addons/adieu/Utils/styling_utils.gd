class_name AdieuStyling;

const KEYS = {
	"DISPLAY_SECTION_HEADER": "display-section-header",
	"DISPLAY_SECTION_CONTEXT": "display-section-context",
	"EVENT_ON": "event-on", # 'Enter',  'Exit'
	"MIN_HEIGHT": "min-height",
	"SECTION_GAP": "section-gap",
	"GAP": "gap",
	"LOAD_TSCN": "load-tscn",
	"HEADER_ALIGN": "header-align", # internally calls same as text-align
	"CONTEXT_ALIGN": "context-align", # internally calls same as text-align
	"TEXT_ALIGN": "text-align",
	"HEADER_SIZE": "header-size", # internally calls same as text-size
	"CONTEXT_SIZE": "context-size", # internally calls same as text-size
	"TEXT_SIZE": "text-size",
	"HEADER_COLOR": "header-color", # internally calls same as text-color
	"CONTEXT_COLOR": "context-color", # internally calls same as text-color
	"TEXT_COLOR": "text-color",
	"HEADER_CAPS": "header-caps", # internally calls same as text-caps
	"CONTEXT_CAPS": "context-caps", # internally calls same as text-caps
	"TEXT_CAPS": "text-caps"
};

# --- Utilities ---

static func merge_styling(override_entries: bool, ...styling_dicts: Array) -> Dictionary:
	var merger = {};

	for styling in styling_dicts:
		var dup = styling.duplicate();
		merger.merge(dup, override_entries);

	return merger;

# --- General Checks ---

static func should_display_header(styling: Dictionary) -> bool:
	if styling.has(KEYS.DISPLAY_SECTION_HEADER):
		return styling.get(KEYS.DISPLAY_SECTION_HEADER).to_lower() == "true";
	return true;

static func should_display_context(styling: Dictionary) -> bool:
	if styling.has(KEYS.DISPLAY_SECTION_CONTEXT):
		return styling.get(KEYS.DISPLAY_SECTION_CONTEXT).to_lower() == "true";
	return true;

static func has_content_to_inject(styling:Dictionary) -> bool:
	return styling.has(KEYS.LOAD_TSCN);

# --- Content Injection ---

static func load_packed_scene(uid: String) -> PackedScene:
	if ResourceLoader.exists(uid):
		var packed_scene = ResourceLoader.load(uid);
		return packed_scene;
	else:
		push_error("[ADIEU] Failed to load packed scene with UID -> ", uid);
		return null;

# --- Section Styling ---

static func apply_min_height(value: String, control: Control):
	if value.is_valid_int():
		var intified = value.to_int();
		control.custom_minimum_size.y = intified;

static func apply_gap(value: String, box_container: BoxContainer):
	if value.is_valid_int():
		var intified = value.to_int();
		box_container.add_theme_constant_override("separation", intified);

# --- Event Management ---

enum EVENT_ON { Enter, Exit }
static func get_event_on_mode(value: String, default: EVENT_ON) -> EVENT_ON:
	match value.to_lower():
		"enter": return EVENT_ON.Enter;
		"exit": return EVENT_ON.Exit;
		_: return default;

# --- Text Styling ---

static func apply_text_align(value: String, label: Label):
	match value.to_lower():
		"left": label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT;
		"center": label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER;
		"right": label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT;
		"fill": label.horizontal_alignment = HORIZONTAL_ALIGNMENT_FILL;

static func apply_text_size(value: String, label: Label):
	if value.is_valid_int():
		var intified = value.to_int();
		label.label_settings.font_size = intified;

static func apply_text_color(value: String, label: Label):
	if value.is_valid_html_color():
		var col = Color.from_string(value, Color.WHITE);
		label.label_settings.font_color = col;

static func apply_text_caps(value: String, label: Label):
	if value.to_lower() == "true":
		label.uppercase = true;
	elif value.to_lower() == "false":
		label.uppercase = false;
