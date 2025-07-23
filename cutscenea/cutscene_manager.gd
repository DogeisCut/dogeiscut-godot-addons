extends Node

var active_cutscene_instances: Array[CutsceneInstance]

signal cutscene_instance_created(cutscene_instance: CutsceneInstance)

func play(caller: Node, cutscene: Cutscene) -> CutsceneInstance:
	var instance: CutsceneInstance = CutsceneInstance.new(caller, cutscene)
	cutscene_instance_created.emit(instance)
	active_cutscene_instances.append(instance)
	instance.finished.connect(
		func():
			active_cutscene_instances.erase(instance)
	)
	return 
