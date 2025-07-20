extends CutsceneEvent
class_name CutsceneEventWait

@export var seconds: float = 1

func _run(_cutscene_instance: CutsceneInstance, _cutscene_player: Node) -> void:
	await CutsceneManager.get_tree().create_timer(seconds).timeout
	finished.emit()
