extends MeshInstance3D

@onready var colShape := $StaticBody3D/CollisionShape3D
@onready var iceGrad := preload("res://src/themes/iceGradient.tres")
@onready var isGrad := preload("res://src/themes/islandGradient.tres")
@onready var isGradCol := preload("res://src/themes/islandGradientColor.tres")
@export var chunkSize := 2.0
@export var heightRatio := 1.0
@export var colShapeSizeRatio := 1.0/8
@export var size := 512
@export var debrisDensity := 0.02
@export var noiseFrequency := .01

@export var debrisMesh : PackedScene
@export var fishSpotMesh : PackedScene

var img := Image.new()
var img2 := Image.new()
var shape := HeightMapShape3D.new()
var textNoise := NoiseTexture2D.new()
var iceText := NoiseTexture2D.new()
var normals := NoiseTexture2D.new()
var tNoise := FastNoiseLite.new()

func _ready():
	mesh.size = Vector2(chunkSize,chunkSize)
	mesh.subdivide_width = size
	mesh.subdivide_depth = size
	
	tNoise.noise_type = FastNoiseLite.TYPE_VALUE
	tNoise.seed = randi()
	tNoise.frequency = noiseFrequency
	
	textNoise.width = size
	textNoise.height = size
	textNoise.noise = tNoise
	
	normals.width = size
	normals.height = size
	normals.noise = tNoise
	normals.as_normal_map = true
	
	iceText.width = size
	iceText.height = size
	iceText.noise = tNoise
	iceText.color_ramp = iceGrad
	
	isGrad.width = size
	isGrad.height = size

	isGradCol.width = size
	isGradCol.height = size
	
	#tNoise = material_override.get("shader_parameter/heightmap").noise
	#textNoise = material_override.get("shader_parameter/heightmap")
	#iceText = material_override.get("shader_parameter/_a")
	#normals = material_override.get("shader_parameter/normals")
	
	updateTerrain()
	createDebris()
	fishingSpots()

func updateTerrain():
	material_override.set("shader_parameter/heightmap", textNoise)
	material_override.set("shader_parameter/heightRatio", heightRatio)
	material_override.set("shader_parameter/_a", iceText)
	material_override.set("shader_parameter/normals", normals)
	
	img = tNoise.get_image(size,size,false,false,true)
	img.convert(Image.FORMAT_RF)
	img.resize(int(size*colShapeSizeRatio), int(size*colShapeSizeRatio))
	img2 = isGrad.get_image()
	img2.convert(Image.FORMAT_RF)
	img2.resize(int(size*colShapeSizeRatio), int(size*colShapeSizeRatio))
	var data = img.get_data().to_float32_array()
	var data2 = img2.get_data().to_float32_array()
	
	for i in range(data.size()):
		data[i] *= data2[i] * heightRatio

	shape.map_width = img.get_width()
	shape.map_depth = img.get_height()
	shape.map_data = data
	colShape.shape = shape
	var scaleRatio = chunkSize/float(img.get_width())
	colShape.scale = Vector3(scaleRatio, 1, scaleRatio)
	
func createDebris():
	for i in range(shape.map_width):
		for j in range(shape.map_depth):
			if shape.map_data[i*shape.map_depth+j] >= 1:
				if randf() <= debrisDensity:
					var m = debrisMesh.instantiate()
					var scaleRatio = chunkSize/float(img.get_width())
					var valid = true
					
					m.position = Vector3((j-shape.map_width/2.0)*scaleRatio, shape.map_data[i*shape.map_depth+j], (i-shape.map_depth/2.0)*scaleRatio)
					for child in get_tree().root.get_node("main").get_node("%debris").get_children():
						if abs((m.position - child.position).length()) <= 1:
							m.queue_free()
							valid = false
							break
					if !valid:
						continue
					get_tree().root.get_node("main").get_node("%debris").add_child(m)

func fishingSpots():
	for i in range(shape.map_width):
		for j in range(shape.map_depth):
			if shape.map_data[i*shape.map_depth+j] < .8 and shape.map_data[i*shape.map_depth+j] >= .4:
				if randf() <= debrisDensity:
					var m = fishSpotMesh.instantiate()
					var scaleRatio = chunkSize/float(img.get_width())
					var valid = true
					
					m.position = Vector3((j-shape.map_width/2.0)*scaleRatio, 1, (i-shape.map_depth/2.0)*scaleRatio)
					for child in get_tree().root.get_node("main").get_node("%fishSpots").get_children():
						if abs((m.position - child.position).length()) <= 2:
							m.queue_free()
							valid = false
							break
					if !valid:
						continue
					get_tree().root.get_node("main").get_node("%fishSpots").add_child(m)
