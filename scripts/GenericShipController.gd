extends KinematicBody

## Provided Signals
#signal value_changed(new_value)

## Exported vars
export(Array, NodePath) var hardPoints : Array
export(PackedScene) var packedLaser : PackedScene
export var maxSpeed : float = 500
export var isPlayer = false

## Internal Vars
onready var anim : AnimationPlayer = $AnimationPlayer
# TODO: Add Behavior here.


var roll_input : float = 0
var yaw_input : float = 0
var pitch_input : float = 0
var inertia : Vector3 = Vector3(0,0,0)
onready var currentSpeed : float = maxSpeed
onready var targetSpeed : float = currentSpeed

var boostModeOn := true
var isFiring := false
var fireAgain = 0

var tween := Tween.new()

## Methods
func _ready():
	pass
#	add_child(tween)
#	tween.interpolate_property(self, "transform",
#		transform.translated(Vector3(0,0,-500)),
#		transform, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	tween.start()

func _process(delta):
	if tween.is_active():
		return
	
	if yaw_input == 0 and pitch_input == 0 and roll_input == 0:
		#inertia.slerp(Vector3(), 0.25)
		inertia = lerp(inertia, Vector3(0,0,0), 0.05)
	else:
		var new = Vector3()
		new.z = PI * ((0.0025 * yaw_input) + (0.005 * roll_input))
		new.y = PI * -1 * 0.005 * yaw_input
		new.x = PI * 0.0075 * pitch_input
		inertia = lerp(inertia, new, 0.05)
		
	if isFiring:
		fireAgain -= delta
		fire_all()
	
	self.rotate(transform.basis.z, inertia.z)
	self.rotate(transform.basis.y, inertia.y)
	self.rotate(transform.basis.x, inertia.x)
	
	currentSpeed = lerp(currentSpeed, targetSpeed, 0.25)
	self.move_and_collide(transform.basis.z * (currentSpeed * 0.01) * delta, false)

func fire_all():
	if fireAgain < 0:
		if boostModeOn:
			fireAgain = 0.66 # If they are closed, the radiators are less efficient.
		else:
			fireAgain = 0.25
	else:
		return
	
	for hardPointPath in hardPoints:
		var hardPoint : Position3D = get_node(hardPointPath)
		if hardPoint.has_method("fire"):
			hardPoint.fire(get_parent(), self.transform.basis)
		##var laser : RebelLaser = packedLaser.instance()
		##get_parent().add_child(laser)
		##laser.transform.origin = hardPoint.global_transform.origin
		##laser.transform.basis = self.transform.basis

func _input(event):
	if !isPlayer: # TODO: Move this all to a PlayerBehavior object.
		return
	
	if event.is_action_pressed("fire_all"):
		isFiring = true
	elif event.is_action_released("fire_all"):
		isFiring = false
	
	if event.is_action_released("ui_select"):
		if boostModeOn:
			if anim:
				anim.play_backwards("CloseSFoils")
			targetSpeed = maxSpeed * 0.5
			#$CameraPivot.goSlow()
		else:
			if anim:
				anim.play("CloseSFoils")
			targetSpeed = maxSpeed
			#$CameraPivot.goFast()
		boostModeOn = !boostModeOn
	
	if event.is_action_pressed("ui_left"):
		yaw_input -= 1
	if event.is_action_released("ui_left"):
		yaw_input += 1
	if event.is_action_pressed("ui_right"):
		yaw_input += 1
	if event.is_action_released("ui_right"):
		yaw_input -= 1
		
	if event.is_action_pressed("ui_down"):
		pitch_input -= 1
	if event.is_action_released("ui_down"):
		pitch_input += 1
	if event.is_action_pressed("ui_up"):
		pitch_input += 1
	if event.is_action_released("ui_up"):
		pitch_input -= 1
	
	if event.is_action_released("roll_left") or event.is_action_released("roll_right"):
		roll_input = 0
	if event.is_action_pressed("roll_left"):
		roll_input = -1
	if event.is_action_pressed("roll_right"):
		roll_input = 1
	
	if event is InputEventScreenDrag:
		var screenSize := get_viewport().get_visible_rect().size
		var screenSizeHalved := screenSize * 0.5
		var event_position = event.position
		#print (str(event_position.x-screenSizeHalved.x), ", ", str(event_position.y-screenSizeHalved.y))
		yaw_input = (event_position.x-screenSizeHalved.x) / screenSizeHalved.x
		pitch_input = (event_position.y-screenSizeHalved.y) / screenSizeHalved.y
	
	if event is InputEventScreenTouch:
		if !event.pressed:
			yaw_input = 0
			pitch_input = 0

## Connected Signals
func hit():
	print("Ship hit!!!")
