extends PanelContainer

@export var label_parent: Control
@export var monitors: Array[Performance.Monitor]
@export var labels: Array[Label]

func _ready():
	for child in label_parent.get_children():
		child.queue_free()
	
	for monitor in monitors:
		var label = Label.new()
		label_parent.add_child(label)
		labels.append(label)

func _process(_delta: float) -> void:
	for i in range(monitors.size()):
		_update_monitor_text(i)

func _update_monitor_text(idx: int):
	var monitor = monitors[idx]
	var label := _monitor_label(monitor)
	var value := _monitor_value(monitor)
	labels[idx].text = "%s: %s" % [label, value]

func _monitor_value(monitor: Performance.Monitor) -> String:
	var raw := Performance.get_monitor(monitor)
	match monitor:
		Performance.TIME_FPS:
			return str(int(raw))
		Performance.MEMORY_STATIC, \
		Performance.MEMORY_STATIC_MAX:
			return "%.1f MB" % (raw / 1_048_576.0)
		Performance.RENDER_TOTAL_OBJECTS_IN_FRAME:
			return str(int(raw))
		_:
			return "%.2f" % raw

func _monitor_label(monitor: Performance.Monitor) -> String:
	match monitor:
		Performance.TIME_FPS:             return "FPS"
		Performance.TIME_PROCESS:         return "Process"
		Performance.TIME_PHYSICS_PROCESS: return "Physics"
		Performance.MEMORY_STATIC:        return "Memory Usage"
		Performance.MEMORY_STATIC_MAX:    return "Memory Peak"
		Performance.RENDER_TOTAL_OBJECTS_IN_FRAME: return "Object Count"
		Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME: return "Draw Calls"
		Performance.RENDER_VIDEO_MEM_USED: return "Video Mem"
		Performance.PHYSICS_2D_ACTIVE_OBJECTS: return "2D Objects"
		Performance.PHYSICS_3D_ACTIVE_OBJECTS: return "3D Objects"
		_: return "Monitor %d" % monitor
