extends Node

#Basic configuration for different areas
const TERRAIN_CHUNK_SIZE = Vector2(50,50) #Size of each terrain piece in X/Z
const TERRAIN_CHUNK_HEIGHT = 1.0 # Thickness for collision/visuals

const BIOME_DATA = {
	"center": {
		"color": Color.DARK_GREEN,
		"base_height": 0.0
	},
	"grass": {
		"color": Color.GREEN,
		"base_height": 0.0
	},
	"desert": {
		"color": Color.SANDY_BROWN,
		"base_height": -0.3
	},
	"mountains": {
		"color": Color.DARK_GRAY,
		"base_height": 1.0, # Higher base
		"mountain_height_scale": 15.0, # How tall mountains are
		"mountain_frequency": 0.05 # How rugged the noise is
	},
	"village": {
		"color": Color.BEIGE, # Ground color for village
		"base_height": 0.0
	}
}
