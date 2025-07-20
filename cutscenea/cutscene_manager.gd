extends Node

var active_cutscene_instances: Array[CutsceneInstance]

func play(caller: Node, cutscene: Cutscene) -> CutsceneInstance:
	var instance: CutsceneInstance = CutsceneInstance.new(caller, cutscene)
	active_cutscene_instances.append(instance)
	instance.finished.connect(
		func():
			active_cutscene_instances.erase(instance)
	)
	return 
