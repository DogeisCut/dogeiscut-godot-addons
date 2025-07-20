@tool
extends EditorPlugin

var sb3_importer: EditorImportPlugin = EditorSceneFormatImporterSB3.new()

func _enter_tree():
	add_import_plugin(sb3_importer)


func _exit_tree():
	remove_import_plugin(sb3_importer)
