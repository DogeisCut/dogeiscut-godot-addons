@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("BigInt", "RefCounted", preload('big_int.gd'), preload('big_int.svg'))


func _exit_tree():
	remove_custom_type("BigInt")
