extends Node

@onready var iceGrad := preload("res://src/themes/iceGradient.tres")
@onready var isGrad := preload("res://src/themes/islandGradient.tres")

@onready var chunk := preload("res://src/actors/env/terrainChunk.tscn")
@onready var isGradCol := preload("res://src/themes/islandGradientColor.tres")
#@export var chunkSize := 2.0
@export var heightRatio := 2.0
@export var size := 32
@export var numChunks := 4
@export var debrisDensity := 0.02

var img := Image.new()
var img2 := Image.new()

var shape := HeightMapShape3D.new()
var textNoise := NoiseTexture2D.new()
var iceText := NoiseTexture2D.new()
var normals := NoiseTexture2D.new()

var tNoise := FastNoiseLite.new()

var dataChunked := []

func _ready():
	var texts = [textNoise, normals, iceText]
	var grads = [isGrad,isGradCol]
	
	tNoise.noise_type = FastNoiseLite.TYPE_VALUE
	tNoise.seed = randi()
	
	for text in texts:
		text.width = size
		text.height = size
		text.noise = tNoise

	for grad in grads:
		grad.height = size
		grad.width = size
	
	normals.as_normal_map = true
	iceText.color_ramp = iceGrad
	
	createChunkData()
	generateChunks()

func createChunkData():
	#material_override.set("shader_parameter/heightmap", textNoise)
	#material_override.set("shader_parameter/heightRatio", heightRatio)
	#material_override.set("shader_parameter/_a", iceText)
	#material_override.set("shader_parameter/normals", normals)
	
	img = tNoise.get_image(size,size,false,false,true)
	img.convert(Image.FORMAT_RF)
	img2 = isGrad.get_image()
	img2.convert(Image.FORMAT_RF)
	var data = img.get_data().to_float32_array()
	var data2 = img2.get_data().to_float32_array()
	
	for i in range(data.size()):
		data[i] *= data2[i] * heightRatio
	
	var data2D := []
	
	for i in range(size):
		data2D.append([])
		for j in range(size):
			data2D[i].append(data[i*size+j])
	
	var sizeChunks = int(size/float(numChunks))
	
	for i in range(numChunks):
		dataChunked.append([])
		for j in range(numChunks):
			dataChunked[i].append([])
			for k in range(sizeChunks):
				for l in range(sizeChunks):
					dataChunked[i][j].append(data2D[i*numChunks+k][j*numChunks+l])

func generateChunks():
	for i in range(numChunks):
		for j in range(numChunks):
			var c = chunk.instantiate()
			c.heightRatio = heightRatio
			c.size = int(size/float(numChunks))
			c.offset = Vector2(i,j)
			add_child(c)
			c.create()
