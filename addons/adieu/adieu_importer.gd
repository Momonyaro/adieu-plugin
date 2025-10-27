@tool
extends EditorImportPlugin

func _get_importer_name():
	return "adieu.importer.plugin";

func _get_priority() -> float:
	return 1.0;

func _get_format_version() -> int:
	return 1;

func _can_import_threaded() -> bool:
	return false;

func _get_visible_name() -> String:
	return "Adieu Importer";

func _get_recognized_extensions():
	return ["adieu"];

func _get_save_extension() -> String:
	return "tres";

func _get_resource_type():
	return "AdieuResource";

func _get_preset_count() -> int:
	return 1;

func _get_preset_name(preset_index: int) -> String:
	return "Default";

func _get_import_options(path: String, preset_index: int):
	return [];

func _import(source_file: String, save_path: String, options: Dictionary, platform_variants, gen_files):
	var parser = AdieuParser.new();

	var resource := AdieuResource.new();
	resource.set("data", parser.parse_file(source_file));

	var filename = save_path + "." + _get_save_extension();
	return ResourceSaver.save(resource, filename);
