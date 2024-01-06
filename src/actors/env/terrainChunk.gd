extends MeshInstance3D

@onready var colShape := $StaticBody3D/CollisionShape3D
@onready var iceGrad := preload("res://src/themes/iceGradient.tres")
@onready var isGrad = preload("res://src/themes/islandGradient.tres")
@onready var isGradCol = preload("res://src/themes/islandGradientColor.tres")
@export var chunkSize = 1.0
@export var heightRatio = 1.0
@export var size = 2
@export var debrisDensity = 0.02

@export var offset = Vector2(0,0)

var shape := HeightMapShape3D.new()
var textNoise := NoiseTexture2D.new()
var iceText := NoiseTexture2D.new()
var normals := NoiseTexture2D.new()
var tNoise := FastNoiseLite.new()

var data : PackedFloat32Array

var chunker

func create():
	chunker = get_parent()
	
	mesh.size = Vector2(chunkSize,chunkSize)
	mesh.subdivide_width = size
	mesh.subdivide_depth = size
	
	data = chunker.dataChunked[offset.x][offset.y]
	
	var texts = [textNoise, normals, iceText]
	var grads = [isGrad, isGradCol]
	
	tNoise.noise_type = FastNoiseLite.TYPE_VALUE
	tNoise.seed = chunker.tNoise.seed
	tNoise.offset = Vector3(offset.x*size,0,offset.y*size)
	
	position = Vector3(offset.x*chunkSize,0,offset.y*chunkSize)
	
	for text in texts:
		text.width = size
		text.height = size
		text.noise = tNoise
		text.seamless = true

	for grad in grads:
		grad.height = size
		grad.width = size
	
	isGrad = chunker.isGrad.get_image().get_region(Rect2i(Vector2i(offset.x * size, offset.y * size), Vector2i(size,size)))
	isGradCol = chunker.isGrad.get_image().get_region(Rect2i(Vector2i(offset.x * size, offset.y * size), Vector2i(size,size)))
	
	normals.as_normal_map = true
	iceText.color_ramp = iceGrad
	
	updateTerrain()

func updateTerrain():
	material_override.set("shader_parameter/heightmap", textNoise)
	material_override.set("shader_parameter/heightRatio", heightRatio)
	material_override.set("shader_parameter/_a", iceText)
	material_override.set("shader_parameter/normals", normals)
	material_override.set("shader_parameter/radialHeight", isGrad)
	material_override.set("shader_parameter/radialColor", isGradCol)
	
	shape.map_width = size
	shape.map_depth = size
	shape.map_data = data
	colShape.shape = shape
	
	var scaleRatio = chunkSize/float(size-1)
	colShape.scale = Vector3(scaleRatio, 1, scaleRatio)
