extends Resource
class_name CutsceneEvent

signal finished

## This method should be overridden by subclasses to implement custom event behavior. It should also emit `finished` when done so the cutscene manager doesn't hang.
func _run(_cutscene_manager: CutsceneInstance, _cutscene_player: Node) -> void:
	finished.emit()

func do_event(cutscene_instance: CutsceneInstance, cutscene_player: Node) -> CutsceneEvent:
	_run.call_deferred(cutscene_instance, cutscene_player)
	return self
