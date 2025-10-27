class_name AdieuStyling;

const KEYS = {
	"DISPLAY_SECTION_HEADER": "display-section-header",
	"HEADER_ALIGN": "header-align", # internally calls same as text-align
	"HEADER_SIZE": "header-size", # internally calls same as text-size
	"HEADER_COLOR": "header-color" # internally calls same as text-color
};

static func should_display_header(styling: Dictionary) -> bool:
	if styling.has(KEYS.DISPLAY_SECTION_HEADER):
		return styling.get(KEYS.DISPLAY_SECTION_HEADER).to_lower() == "true";
	return true;

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
