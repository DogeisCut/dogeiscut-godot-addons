extends CutsceneEvent

@export var cutscene: Cutscene
@export var wait_until_finished: bool = true

func _run(_cutscene_instance: CutsceneInstance, cutscene_player: Node) -> void:
	var cutscene = CutsceneManager.play(cutscene_player, cutscene)
	if wait_until_finished:
		await cutscene.finished
	finished.emit()
