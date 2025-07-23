extends Resource
class_name CutsceneInstance

signal finished

enum Statuses {
	CREATED,
	STARTING,
	PLAYING,
	WAITING,
	FINISHED,
	FAILED
}

var status: Statuses = Statuses.CREATED
var cutscene: Cutscene

func _init(caller: Node, set_cutscene: Cutscene):
	cutscene = set_cutscene
	_do(caller, set_cutscene)

func _do(caller: Node, set_cutscene: Cutscene):
	status = Statuses.STARTING
	for event: CutsceneEvent in set_cutscene.events:
		assert(event, "Empty or null event.")
		assert(event.has_method("_run"), "Event %s is missing _run method. Is it a CutsceneEvent?" % event)
		assert(event.has_method("do_event"), "Event %s is missing do_event method. Is it a CutsceneEvent?" % event)
	for event: CutsceneEvent in set_cutscene.events:
		status = Statuses.WAITING
		await event.do_event(self, caller).finished
		status = Statuses.PLAYING
	status = Statuses.FINISHED
	finished.emit()
