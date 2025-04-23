extends Node3D

@export var segment_scenes: Array[PackedScene]
@export var initial_segment_count: int = 2
@export var player: NodePath

var player_ref: Node3D
var segments: Array[Node3D] = []

func _ready():
	player_ref = get_node(player)
	_spawn_initial_segments()

	
func _spawn_initial_segments():
	var last_exit_position = global_transform.origin
	print("DEBUG - segment_scenes size: ", segment_scenes.size())

	for i in range(initial_segment_count):
		if segment_scenes.size() == 0:
			printerr("🚨 No segment scenes loaded! Cannot spawn segments.")
			return  # Stop before crashing

		var scene = segment_scenes[randi() % segment_scenes.size()]
		var segment = scene.instantiate()
		add_child(segment)

		segment.global_transform.origin = last_exit_position
		segments.append(segment)

		var exit_marker = segment.get_node_or_null("ExitPoint")
		if exit_marker:
			last_exit_position = exit_marker.global_transform.origin


func _process(delta):
	if segments.size() < 2:
		return

	var player_z = player_ref.global_transform.origin.z
	var first = segments[0]
	var exit_marker = first.get_node_or_null("ExitPoint")
	if exit_marker and player_z > exit_marker.global_transform.origin.z:
		# Recycle the first segment to the end
		segments.pop_front()
		var new_scene = segment_scenes[randi() % segment_scenes.size()]
		var new_segment = new_scene.instantiate()
		add_child(new_segment)

		# Position it at the end of the last segment
		var last_exit = segments[-1].get_node_or_null("ExitPoint")
		if last_exit:
			new_segment.global_transform.origin = last_exit.global_transform.origin

		segments.append(new_segment)
		first.queue_free()
