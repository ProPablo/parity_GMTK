extends KinematicBody2D

export var GRAVITY = 98;

var velocity = Vector2()
var mass = 1;
var points = 1;
var is_slotted = false;

var current_item = "Student_bike"

# Called when the node enters the scene tree for the first time.
func _ready():
	var current_act = "Act1" # placeholder
	# var dict_keys = $"/root/Global".asset_dict[current_act].keys()
	# var rand_index = round(rand_range(0, dict_keys.size() - 1)) ;
	# print(rand_index)
	# var current_item = dict_keys[rand_index] # placeholder
	
#	var slot_to_add = $"/root/Main".slots[0];
#	get_parent().remove_child(self)
#	slot_to_add.add_child(self)

	
	_loadJSON(current_act, current_item);

func _loadJSON(current_act, current_item):
	var dict = $"/root/Global".asset_dict
	var current_data = dict[current_act][current_item]
	
	$ItemSprite.texture = load(current_data["text"])
	$CollisionShape2D.set_shape(load(current_data["collision"]));
	if current_data.has("region"):
		$ItemSprite.region_enabled = true
		var reg = current_data["region"]
		$ItemSprite.region_rect = Rect2(reg[0], reg[1], reg[2], reg[3])
	if current_data.has("scale"):
		var scale = current_data["scale"]
		$ItemSprite.scale = Vector2(scale[0], scale[1]);
	
	var animation_frames = 1;
	if current_data.has("hf"):
		$ItemSprite.hframes = current_data["hf"]
		animation_frames *= current_data["hf"]
	if current_data.has("vf"):
		$ItemSprite.vframes = current_data["vf"]
		animation_frames *= current_data["vf"]
	if current_data.has("anim"):
		var anim = Animation.new()
		var track_index = anim.add_track(Animation.TYPE_VALUE)
		var exclude = []
		if current_data.has("fexclude"):
			exclude = current_data["fexclude"]
#			print(exclude)
		 
		anim.track_set_path(track_index, "ItemSprite:frame")
		
		var frame_length = current_data["anim"] / float(animation_frames - exclude.size());
		for n in animation_frames:
			if exclude.has(n):
				print("skipping" + str(n))
				continue
			anim.track_insert_key(track_index,frame_length*n , n);
			print(n)

		anim.loop = true;
		$ItemAnim.add_animation("item_anim", anim)
		$ItemAnim.play("item_anim")

	if current_data.has("mass"):
		mass = current_data["mass"]
	if current_data.has("points"):
		points = current_data["points"]
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if is_slotted:
		return
	velocity += Vector2(0,1) * GRAVITY * delta;
	move_and_slide(velocity);

func item_to_inventory(slot_number):
	print("Going to slot" + str(slot_number))
	if is_slotted:
		return
	
	is_slotted = true;
	$CollisionShape2D.disabled = true;
	collision_layer = 0;
	var slot = $"/root/Main".slots[slot_number];
	
	var rect = $ItemSprite.get_rect();
	if (rect.size.x >=rect.size.y):
		var new_scale = $"/root/Main".slot_size / rect.size.x;
		$ItemSprite.scale *= new_scale;
	else:
		var new_scale = $"/root/Main".slot_size / rect.size.y;
		$ItemSprite.scale *= new_scale;
	
	
	get_parent().remove_child(self)
	slot.add_child(self)
	
	velocity = Vector2(0,0)
	position = Vector2(0,0)
	# position = Vector2($Main.slot_offset + slot_number * $Main.slot_increment, $Main.slot_height)
