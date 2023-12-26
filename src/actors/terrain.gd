extends MeshInstance3D

@onready var colShape := $StaticBody3D/CollisionShape3D
@onready var iceGrad := preload("res://src/themes/iceGradient.tres")
@onready var isGrad := preload("res://src/themes/islandGradient.tres")
@onready var isGradCol := preload("res://src/themes/islandGradientColor.tres")
@export var chunkSize := 2.0
@export var heightRatio := 1.0
@export var colShapeSizeRatio := 1.0/8
@export var size := 512

var img := Image.new()
var img2 := Image.new()
var shape := HeightMapShape3D.new()
var textNoise := NoiseTexture2D.new()
var iceText := NoiseTexture2D.new()
var normals := NoiseTexture2D.new()
var tNoise := FastNoiseLite.new()

func _ready():
	colShape.shape = shape
	mesh.size = Vector2(chunkSize,chunkSize)
	mesh.subdivide_width = size-1
	mesh.subdivide_depth = size-1
	
	tNoise.noise_type = FastNoiseLite.TYPE_VALUE
	tNoise.seed = randi()
	
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

func updateTerrain():
	material_override.set("shader_parameter/heightmap", textNoise)
	material_override.set("shader_parameter/heightRatio", heightRatio)
	material_override.set("shader_parameter/_a", iceText)
	material_override.set("shader_parameter/normals", normals)
	
	img = tNoise.get_image(size,size,false,false,true)
	img.convert(Image.FORMAT_RF)
	#img.resize(int(size*colShapeSizeRatio), int(size*colShapeSizeRatio))
	img2 = isGrad.get_image()
	img2.convert(Image.FORMAT_RF)
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

func _process(_delta):
	pass
