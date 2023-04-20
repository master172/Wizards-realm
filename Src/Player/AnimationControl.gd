extends AnimationTree


# Called when the node enters the scene tree for the first time.

var iwr_blend = "parameters/Iwr_blend/blend_amount"
var jump_one_shot = "parameters/jump_oneshot/active"
var jump_transition = "parameters/JumpTransistion/current"

var direction = Vector2(0,0)

@onready var mesh = get_node("%Model1")

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var tween_value = 0.0
var run_value = 0.0 
var lerp_direction = Vector2()
var magic_tween_value = 0.0
var magic_tween_tranisition_value = 1.0

var jumping = false
var magic_attack = false

func _physics_process(delta):
	
	if self.get_parent().is_on_floor():
		if jumping == false:
			var tween = get_tree().create_tween()
			tween.tween_property(self, "tween_value", 0.0, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
			set("parameters/FallingBlend/blend_amount",tween_value)
		else:
			set("parameters/LandingOneshot/request",1)
			jumping = false
	else:
		jumping = true
		var tween = get_tree().create_tween()
		tween.tween_property(self, "tween_value", 1.0, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		set("parameters/FallingBlend/blend_amount",tween_value)
	
	
	
	if Input.is_action_pressed("D") || Input.is_action_pressed("A") || Input.is_action_pressed("W") || Input.is_action_pressed("S"):
		
		direction = Vector2(Input.get_action_strength("A")-Input.get_action_strength("D"),Input.get_action_strength("W")-Input.get_action_strength("S"))
		
		if Input.is_action_pressed("sprint"):
			var tween = get_tree().create_tween()
			tween.tween_property(self, "run_value", 1.0, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
			
			set("parameters/IWR_blend/blend_amount",run_value)
			
			var tween2 = get_tree().create_tween()
			tween2.tween_property(self, "lerp_direction", direction, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
			
			set("parameters/RunStateMachine/Run/blend_position",lerp_direction)
			
		else:
			var tween = get_tree().create_tween()
			tween.tween_property(self, "run_value", -1.0, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
			set("parameters/IWR_blend/blend_amount",run_value)
			
			var tween2 = get_tree().create_tween()
			tween2.tween_property(self, "lerp_direction", direction, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
			
			set("parameters/Walk/BlendSpace2D/blend_position",lerp_direction)
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "run_value", 0.0, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		set("parameters/IWR_blend/blend_amount",run_value)
		direction = Vector2(0,0)
	
	if Input.is_action_just_pressed("Jump"):
		if self.get_parent().magic == false:
			jumping = true
	
	if self.get_parent().is_on_floor():
		if Input.is_action_pressed("mouse_left"):
			#var tween = get_tree().create_tween()
			
			#tween.tween_property(self, "magic_tween_value", 32.0, 32).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
				
			set("parameters/MagTimeScale/scale",1)
			set("parameters/Magic_blend/blend_amount",1)
			
			magic_tween_tranisition_value = 1.0
			magic_attack = true
		else:
			if magic_attack == true:
				var tween = get_tree().create_tween()
				tween.tween_property(self, "magic_tween_tranisition_value", 0, 1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)

				set("parameters/Magic_blend/blend_amount",magic_tween_tranisition_value)
				await tween.finished
				
				set("parameters/MagTimeScale/scale",-32)
				
				magic_attack = false
				magic_tween_value = 0
		


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Landing":
		jumping = false

