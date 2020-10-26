extends Spatial


signal fire_bullet

var bullet_to_fire = preload("res://ships/green_laser.tscn")
export var bullet_speed = 1500

onready var body = $body
onready var barrel = $body/barrel

var target:KinematicBody
var targetting = false

onready var scanTimer = $ScanTimer

func _ready():
	pass # Replace with function body.

func _process(delta):
	
	pass

func _physics_process(delta):
	if not target:
		return
	
	aim()
	pass

func aim():
	#var desiredRotation = barrel.global_transform.looking_at(target.global_transform.origin, Vector3.UP) # or V3(0,1,0)
	var desiredRotation = self.global_transform.looking_at(target.global_transform.origin, self.global_transform.basis.y)
	var desiredRotationQuat = desiredRotation.basis.get_rotation_quat()
	
	var euler = desiredRotation.basis.get_euler()
	body.global_transform.basis = Basis()
	barrel.global_transform.basis = Basis()
	barrel.rotate_object_local(body.global_transform.basis.x, euler.x)
	body.rotate_object_local(body.global_transform.basis.y, euler.y)

func very_simple_aim():
	#var desiredRotation = barrel.global_transform.looking_at(target.global_transform.origin, Vector3.UP) # or V3(0,1,0)
	var desiredRotation = self.global_transform.looking_at(target.global_transform.origin, self.global_transform.basis.y)
	var desiredRotationQuat = desiredRotation.basis.get_rotation_quat()
	
	#barrel.rotation.x = 
	body.global_transform.basis = desiredRotation.basis

func old_aim():
	#var desiredRotation = barrel.global_transform.looking_at(target.global_transform.origin, Vector3.UP) # or V3(0,1,0)
	var desiredRotation = target.global_transform.looking_at(barrel.global_transform.origin, self.global_transform.basis.y)
	var desiredRotationQuat = desiredRotation.basis.get_rotation_quat()
	var barrelRotationQuat = barrel.global_transform.basis.get_rotation_quat()
	var rotatedQuat = Quat(barrelRotationQuat).slerp(desiredRotationQuat, 0.02)
	#barrel.global_transform.basis = Basis(rotatedQuat)
	var rotatedEuler = Basis(rotatedQuat).get_euler()
	#barrel.rotate_x(rotatedEuler.x)
	#body.rotate_y(rotatedEuler.y)
	
	var barrelRotateX = rotatedEuler.x
	if barrelRotateX > 0:
		barrelRotateX = 0
	#print(barrelRotateX)
	barrel.rotation.x = barrelRotateX
	
	body.rotation.y = rotatedEuler.y


func _on_ScanTimer_timeout():
	## Check if the target has invalidated itself.
	if target:
		if target.global_transform.origin.distance_to(self.global_transform.origin) > 100:
			target = null
	
	## If target is still valid, ditch this method.
	if target:
		return
	
	## If not, do the scan.
	var closest = null
	var closestDist = 100.0
	for node in get_tree().get_nodes_in_group("class_fighter"):
		var dist = node.global_transform.origin.distance_to(self.global_transform.origin)
		
		print(dist)
		if dist < 100:
			closest = node
			closestDist = dist
	
	target = closest
	
	if target == null:
		pass
