extends CutsceneEvent
class_name CutsceneEventAnimation

@export_node_path('AnimationPlayer') var animation_player_path: NodePath
@export var animation_name: StringName
@export var wait_until_finished: bool = true

func _run(_cutscene_instance: CutsceneInstance, cutscene_player: Node) -> void:
	var animation_player: AnimationPlayer = cutscene_player.get_node(animation_player_path)
	if not animation_player or not animation_player.has_animation(animation_name):
		push_error("Invalid AnimationPlayer or animation name: '%s'" % animation_name)
		finished.emit()
		return

	animation_player.play(animation_name)

	if wait_until_finished:
		await animation_player.animation_finished
	finished.emit()
