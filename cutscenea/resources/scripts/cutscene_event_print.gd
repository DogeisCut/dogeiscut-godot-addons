extends CutsceneEvent
class_name CutsceneEventPrint

@export_multiline var text: String

func _run(_cutscene_instance: CutsceneInstance, _cutscene_player: Node) -> void:
	print(text)
	finished.emit()
