@tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("CutsceneManager", "res://addons/cutscenea/cutscene_manager.gd")

func _exit_tree():
	remove_autoload_singleton("CutsceneManager")
