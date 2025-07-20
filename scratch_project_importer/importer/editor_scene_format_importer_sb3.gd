@tool
extends EditorImportPlugin
class_name EditorSceneFormatImporterSB3

func _get_priority():
	return 2.0

func _get_import_order():
	return 0

func _get_importer_name():
	return "scene.sb3"

func _get_visible_name():
	return "Scene"

func _get_recognized_extensions():
	return ["sb3"]

func _get_save_extension():
	return "scn"

func _get_resource_type():
	return "PackedScene"

func _get_preset_count():
	return 1

func _get_preset_name(preset_index):
	return "Default"

func _get_import_options(path, preset_index):
	return [{"name": "import_sounds", "default_value": true},{"name": "transpile_code", "default_value": false}]

func _get_option_visibility(path, option, options):
	return true

func _import(source_file, save_path, options, platform_variants, gen_files):
	
	var root_node
	root_node = ScratchProjectRoot.new() 
	root_node.name = "ScratchProjectRoot"
	root_node.position = Vector2(480,360)
	
	var project_json: Dictionary
	var reader := ZIPReader.new()
	var err := reader.open(source_file)
	if err != OK:
		push_error("Error reading sb3 file. (Invalid or corrupt?)")
		return
	if reader.file_exists("project.json"):
		var res := reader.read_file("project.json")
		var json_string := res.get_string_from_utf8()
		project_json = JSON.parse_string(json_string)
		for sprite in project_json["targets"]:
			var sprite_name = sprite["name"]
			var sprite_node = ScratchSprite.new()
			for costume in sprite["costumes"]:
				var asset_format = costume["dataFormat"]
				var asset_id = costume["assetId"]
				var asset_name = costume["name"]
				var asset := reader.read_file(asset_id + "." + asset_format)
				var img_result = Image.new()
				if asset_format == "png":
					if img_result.load_png_from_buffer(asset) != OK:
						sprite_node.costumes.append(null)
						sprite_node.costume_names.append(asset_name)
						sprite_node.offsets.append(Vector2.ZERO)
						sprite_node.bitmap_resolutions.append(1)
				elif asset_format == "svg":
					if img_result.load_svg_from_buffer(asset) != OK:
						sprite_node.costumes.append(null)
						sprite_node.costume_names.append(asset_name)
						sprite_node.offsets.append(Vector2.ZERO)
						sprite_node.bitmap_resolutions.append(1)
				else:
					push_error("Unknown format type '" + asset_format + "' recieved when trying to import sb3 file.")
				img_result = ImageTexture.create_from_image(img_result)
				sprite_node.costumes.append(img_result)
				sprite_node.costume_names.append(asset_name)
				sprite_node.offsets.append(Vector2(costume["rotationCenterX"], costume["rotationCenterY"]))
				if costume.has("bitmapResolution"):
					sprite_node.bitmap_resolutions.append(costume["bitmapResolution"])
				else:
					sprite_node.bitmap_resolutions.append(1)
				var bitmap = BitMap.new()
				bitmap.create_from_image_alpha(img_result.get_image())
				sprite_node.costume_collisons.append(bitmap.opaque_to_polygons(Rect2(Vector2(), bitmap.get_size()), 0.1))
			if sprite["isStage"] == false:
				sprite_node.scratch_position = Vector2(sprite["x"], sprite["y"])
				sprite_node.scratch_size = sprite["size"]
				sprite_node.direction = sprite["direction"]
				sprite_node.z_index = sprite["layerOrder"]
				sprite_node.visible = sprite["visible"]
				match(sprite["rotationStyle"]):
					"all around":
						sprite_node.rotation_style = ScratchSprite.RotationStyle.ALL_AROUND
					"left-right":
						sprite_node.rotation_style = ScratchSprite.RotationStyle.LEFT_RIGHT
					"don't rotate":
						sprite_node.rotation_style = ScratchSprite.RotationStyle.DONT_ROTATE
			else: 
				sprite_node.scratch_position = Vector2(0, 0)
				sprite_node.z_index = -1000
				sprite_node.direction = 90
				sprite_node.scratch_size = 100
			sprite_node.current_costume = sprite["currentCostume"]
			sprite_node.name = "Stage" if sprite["isStage"] else sprite_name.to_pascal_case()+"Sprite"
			sprite_node.unique_name_in_owner = true
			root_node.add_child(sprite_node)
			sprite_node.owner = root_node
			if options["import_sounds"]:
				for sound in sprite["sounds"]:
					var asset_format = sound["dataFormat"]
					var asset_id = sound["assetId"]
					var asset_name = sound["name"]
					var sound_node: AudioStreamPlayer = AudioStreamPlayer.new()
					var asset := reader.read_file(asset_id + "." + asset_format)
					var audio_result
					if asset_format == "wav":
						audio_result = AudioStreamWAV.new()
						audio_result.format = AudioStreamWAV.FORMAT_16_BITS
						audio_result.data = asset.slice(44, get_data_size_from_wav(asset) + 44)
						audio_result.mix_rate = get_sample_rate_from_wav(asset)
					elif asset_format == "mp3":
						audio_result = AudioStreamMP3.new()
						audio_result.data = asset
					sound_node.name = asset_name.to_pascal_case()+"Sound"
					sound_node.stream = audio_result
					sprite_node.add_child(sound_node)
					sound_node.owner = root_node
	reader.close()
	
	var filename = save_path + "." + _get_save_extension()
	
	var scene = PackedScene.new()
	scene.pack(root_node)
	root_node.free()
	return ResourceSaver.save(scene, filename)

func get_sample_rate_from_wav(wav_data: PackedByteArray) -> int: #sometimes godot makes me wanna bash my head in
	var sample_rate_bytes = wav_data.slice(24, 28)
	var sample_rate = int(sample_rate_bytes[0]) + int(sample_rate_bytes[1]) * 256 + int(sample_rate_bytes[2]) * 65536 + int(sample_rate_bytes[3]) * 16777216
	return sample_rate

func get_data_size_from_wav(wav_data: PackedByteArray) -> int: #once again
	var data_size_bytes = wav_data.slice(40, 44)
	var data_size = int(data_size_bytes[0]) + int(data_size_bytes[1]) * 256 + int(data_size_bytes[2]) * 65536 + int(data_size_bytes[3]) * 16777216
	return data_size

# Step 1: convert block code into some sort of AST
# Step 2: convert AST to godot code
