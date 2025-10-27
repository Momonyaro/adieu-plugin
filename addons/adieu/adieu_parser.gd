extends RefCounted;
class_name AdieuParser;

enum LineType { Section, Context, Text, Styling, Event, Empty }
var persist = {};

func parse_file(file_path: String) -> Dictionary:
	var data: Dictionary = {
		"Sections": []
	};

	if FileAccess.file_exists(file_path) == false:
		return {};

	var file = FileAccess.open(file_path, FileAccess.READ);

	while file.eof_reached() == false:
		var line = file.get_line();
		_parse_line(line, data);

	return data;

func _infer_line_type(line: String) -> LineType:
	var trimmed = line.strip_edges();
	var first_char = trimmed[0] if trimmed.length() > 0 else "";

	if first_char.length() == 0:
		return LineType.Empty;

	match first_char:
		"[": return LineType.Section;
		"<": return LineType.Context;
		"!": return LineType.Styling;
		"$": return LineType.Event;
		_:   return LineType.Text;

func _parse_line(line: String, obj_dict: Dictionary):
	var line_type = _infer_line_type(line);
	match line_type:
		LineType.Section: _parse_section(line, obj_dict);
		LineType.Context: _parse_context(line, obj_dict);
		LineType.Styling: _parse_styling(line, obj_dict);
		LineType.Event:     _parse_event(line, obj_dict);
		LineType.Text:       _parse_text(line, obj_dict);

func _parse_section(line: String, obj_dict: Dictionary):
	var data = {};
	var section_start = line.find('[') + 1;
	var section_end   = line.find(']');

	data["Title"] = line.substr(section_start, section_end - section_start);
	data["Lines"] = [];
	data["Events"] = [];
	data["Styling"] = {};

	obj_dict["Sections"].push_back(data);

func _parse_context(line: String, obj_dict: Dictionary):
	var ctx_start  = line.find('<') + 1;
	var ctx_end    = line.find('>');
	var ctx_string = line.substr(ctx_start, ctx_end - ctx_start);

	# Save new context to persist for later use
	var sections := obj_dict.get("Sections", {});
	if sections.size() > 0:
		var obj = persist.get_or_add(sections[-1].Title, {});
		obj["LatestContext"] = ctx_string;

func _parse_text(line: String, obj_dict: Dictionary):
	var trimmed = line.strip_edges();

	# Insert line into sections array
	var line_item = {
		"Text": trimmed
	};

	var sections := obj_dict.get("Sections", {});
	if sections.size() > 0:
		var obj = persist.get_or_add(sections[-1].Title, {});
		var ctx_exists = obj.has("LatestContext");
		if ctx_exists:
			line_item["Context"] = obj["LatestContext"];

		obj_dict["Sections"][-1]["Lines"].push_back(line_item);

func _parse_styling(line: String, obj_dict: Dictionary):
	var trimmed = line.strip_edges();
	var split = trimmed.split('=', true, 1);

	if split.size() == 1:
		return;

	var key = split[0].replace('!', '');
	var value = split[1].replace('"', '').replace("'", '');

	var sections := obj_dict.get("Sections", {});
	if sections.size() > 0:
		obj_dict["Sections"][-1]["Styling"][key] = value;

func _parse_event(line: String, obj_dict: Dictionary):
	var trimmed = line.strip_edges().replace('$', '');

	var sections := obj_dict.get("Sections", {});
	if sections.size() > 0:
		obj_dict["Sections"][-1]["Events"].push_back(trimmed);
