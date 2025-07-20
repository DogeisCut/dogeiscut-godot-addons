extends Node2D
class_name ScratchProjectRoot
## The root node in which all [ScratchSprite]s sit under.
## @experimental: This is VERY prone to bugs and inacuracies to Scratch. I've tried my best.

var input_queue: Array[StringName]

var project_actions: Array[StringName] = InputMap.get_actions()

## Emitted every game/project tick, useful with [code]await[/code].
signal ticked

## Overwritten to get every [ScratchSprite] child and call [method ScratchSprite._green_flag] 
func _ready():
	for child in get_children():
		if child is ScratchSprite:
			child._green_flag()

## Used to help time when to tick, Scratch runs at 30fps
var tick_timer: float = 0.0
## Replicates the timer from Scratch. Use in a [ScratchSprite] via [code]root.timer[/code].
var timer: float
func _process(delta):
	for action in project_actions:
		if Input.is_action_just_pressed(action):
			input_queue.append(action)
	tick_timer += delta
	timer += delta
	if tick_timer >= (1.0/30.0):
		ticked.emit()
		tick_timer = 0
		for child in get_children():
			child._tick()
		input_queue.clear()
