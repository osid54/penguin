extends MeshInstance3D

@onready var colShape := $StaticBody3D/CollisionShape3D
@onready var iceGrad := preload("res://src/themes/iceGradient.tres")
@export var chunkSize := 2.0
@export var heightRatio := 1.0
@export var colShapeSizeRatio := 1.0/8
@export var size := 512

var img := Image.new()
var shape := HeightMapShape3D.new()
var textNoise := NoiseTexture2D.new()
var iceText := NoiseTexture2D.new()
var normals := NoiseTexture2D.new()
var tNoise

func _ready():
	colShape.shape = shape
	mesh.size = Vector2(chunkSize,chunkSize)
	mesh.subdivide_width = size-1
	mesh.subdivide_depth = size-1
	textNoise.width = size
	textNoise.height = size
	textNoise.noise = FastNoiseLite.new()
	
	tNoise = textNoise.noise
	tNoise.noise_type = FastNoiseLite.TYPE_VALUE
	tNoise.seed = randi()
	
	normals.width = size
	normals.width = size
	normals.noise = tNoise
	normals.as_normal_map = true
	
	iceText.width = size
	iceText.width = size
	iceText.noise = tNoise
	iceText.color_ramp = iceGrad
	
	updateTerrain()

func updateTerrain():
	material_override.set("shader_parameter/heightmap", textNoise)
	material_override.set("shader_parameter/heightRatio", heightRatio)
	material_override.set("shader_parameter/_a", iceText)
	material_override.set("shader_parameter/normals", normals)
	img = tNoise.get_image(size,size,false,false,true)
	img.convert(Image.FORMAT_RF)
	#img.resize(int(size*colShapeSizeRatio), int(size*colShapeSizeRatio))
	var data = img.get_data().to_float32_array()
	for d in data:
		d *= heightRatio
	shape.map_width = img.get_width()
	shape.map_depth = img.get_height()
	shape.map_data = data
	colShape.shape = shape
	var scaleRatio = chunkSize/float(img.get_width())
	colShape.scale = Vector3(scaleRatio, heightRatio, scaleRatio)

func _process(_delta):
	pass
