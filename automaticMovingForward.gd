extends KinematicBody


export var maxSpeed : float = 50
onready var currentSpeed : float = maxSpeed


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.move_and_collide(transform.basis.z * (currentSpeed * 0.01) * delta)
	pass
