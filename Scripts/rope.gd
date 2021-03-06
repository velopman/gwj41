class_name Rope extends Node2D

var RopePiece = preload("res://Parts/RopePiece.tscn")
var piece_length := 6
var rope_parts := []
var rope_close_tolerance := 4
var rope_points : PoolVector2Array = []
var rope_colors : PoolColorArray = []
var rope_to_left := true
var active_rope_id : int = -INF setget set_active_rope_id
var color1 := Color.darkmagenta
var color2 := Color.lightsalmon
var initial_start_position = Vector2.ZERO
var initial_end_position = Vector2.ZERO
var shipMastAttachedTo
var dirty: bool = true
var hasSplashed : bool = true

onready var rope_start_piece = $RopeStartPiece
onready var rope_end_piece = $RopeEndPiece
onready var rope_start_joint = $RopeStartPiece/C/J
onready var rope_end_joint = $RopeEndPiece/C/J

func _ready() -> void:
	add_to_group("tentacle")
	rope_end_piece.add_to_group("ropeEndPiece")

func _physics_process(_delta):
	get_rope_points()
	if rope_points[-1].y > Globals.water_height and !hasSplashed:
		Event.emit_signal("water_splash", rope_end_piece.position.x, 30.0, "tentacle")
		hasSplashed = !hasSplashed
	if  rope_points[-1].y < Globals.water_height and hasSplashed:
		Event.emit_signal("water_splash", rope_end_piece.position.x, -30.0, "tentacle")
		hasSplashed = !hasSplashed
#	if rope_points.size() > 2:
#		update()

func attach_to_ship_mast(mast):
	shipMastAttachedTo = mast

func detatch_from_ship_mast(mast):
	if shipMastAttachedTo == mast:
		shipMastAttachedTo = null
		#disable collision for a short period to make sure we don't accidentally attach to another ship straight away.
		#print(rope_start_piece)
		for child in rope_end_piece.get_children():
			child.set_deferred("disabled", true)
		#rope_start_piece.CollisionShape2D.disabled = true
		#rope_end_piece.CollisionShape2D.disabled = true
			#get_node("CollisionShape2D").disabled = true    # disable
			#rope.get_node("CollisionShape2D").disabled = false   # enable
		$TempCollisionDisable.start()


func get_mast_attached():
	return(shipMastAttachedTo)

func set_active_rope_id(value:int):
	if active_rope_id != value:
		active_rope_id = value
		if active_rope_id == -INF:
			for i in rope_parts:
				(i as RigidBody2D).mass = 1
		else:
			for i in len(rope_parts):
				if i == active_rope_id:
					(rope_parts[i] as RigidBody2D).mass = 10
				else:
					(rope_parts[i] as RigidBody2D).mass = 1

func setRopeEndPoint(newEndPoint:Vector2):
	rope_end_piece.global_position = newEndPoint

func getRopeEndPoint():
	return(rope_end_piece.global_position)

func getInitialStartPosition():
	return(initial_start_position)
func getInitialEndPosition():
	return(initial_end_position)

func resetToInitialPositions():
	rope_start_piece.global_position = initial_start_position
	rope_end_piece.global_position = initial_end_position

func spawn_rope(start_pos:Vector2, end_pos:Vector2):
	rope_start_piece.global_position = start_pos
	rope_end_piece.global_position = end_pos
	start_pos = rope_start_joint.global_position
	end_pos = rope_end_joint.global_position

	rope_to_left = start_pos.x < end_pos.x
	#var distance = start_pos.distance_to(end_pos)
	var pieces_amount = 60
	var spawn_angle = (end_pos - start_pos).angle() - PI/2
	create_rope(pieces_amount, rope_start_piece, end_pos, spawn_angle)
	initial_start_position = start_pos
	initial_end_position = end_pos

func create_rope(pieces_amount:int, parent:Object, end_pos:Vector2, spawn_angle:float) -> void:
	rope_colors.append(color1)
	var last_color
	for i in pieces_amount:
		last_color = color2 if i % 2 == 0 else color1
		rope_colors.append(last_color)

		parent = add_piece(parent, i, spawn_angle)
		parent.set_name("rope_piece_"+str(i))
		rope_parts.append(parent)

		var joint_pos = parent.get_node("C/J").global_position
		if joint_pos.distance_to(end_pos) < rope_close_tolerance:
			break

	last_color = color1 if last_color == color2 else color2
	rope_colors.append(last_color)

	rope_end_joint.node_a = rope_end_piece.get_path()
	rope_end_joint.node_b = rope_parts[-1].get_path()


func add_piece(parent:Object, id:int, spawn_angle:float) -> RopePiece:
	var joint : PinJoint2D = parent.get_node("C/J") as PinJoint2D
	var piece : RopePiece = RopePiece.instance() as RopePiece
	piece.global_position = joint.global_position
	piece.rotation = spawn_angle
	piece.parent = self
	piece.id = id
	add_child(piece)
	joint.node_a = parent.get_path()
	joint.node_b = piece.get_path()
	return piece

func get_rope_points() -> void:
	var new_rope_points = PoolVector2Array()
	new_rope_points.append( rope_start_joint.global_position )
	for r in rope_parts:
		new_rope_points.append( r.global_position )
	new_rope_points.append( rope_end_joint.global_position )

	if new_rope_points != rope_points:
		rope_points = new_rope_points
		dirty = true




#func _draw():
#	if rope_points.size() > 2:
#		draw_polyline_colors(rope_points, rope_colors, 20.0, true)



func _on_TempCollisionDisable_timeout():
	for child in rope_end_piece.get_children():
		child.set_deferred("disabled", false)
