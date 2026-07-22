-- Planning for in-game roblox shader

--[[

shader_type canvas_item;

uniform float var : hint_range(0.0, 10.0) = 1.0;
uniform float fade : hint_range(0.0, 1.0) = 1.0;
uniform float pixel_size : hint_range(0.0, 10.0) = 1.0;
uniform float rad : hint_range(0.0, 1.0) = 1.0;

varying vec2 world_uv;

float lerp(float a,float b,float c) {
	return a + (b - a) * c;
}

float pixilate(float x, float sx) {
	return floor(x*pow(10.0, sx))/pow(10.0, sx);
}

vec2 pixilate2d(vec2 map, float sx) {
	float x = pixilate(map.x, sx);
	float y = pixilate(map.y, sx);
	return vec2(x, y);
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	// COLOR = vec4(floor(UV.y*10.0)/10.0, 0, 0, 1.0);
	
	vec2 center = vec2(0.5, 0.5);
	vec2 vec = UV - center;
	
	float dist = length(pixilate2d(vec, pixel_size));
	float side = (dist < (rad/2.0)) ? 1.0 : 0.0;
	float grad = ((rad/2.0) - dist)*(1.0-fade);
	
	COLOR = texture(TEXTURE, pixilate2d(world_uv, pixel_size) * var);
	COLOR.a *= grad * side;
}

]]

--[[ my fitted coding language to replicated opengl/luau

--!shader_type-canvas_item; -- canvas_item / spatial (3d) || settings identifier

-- defining static variables
local world_uv: Vector2; -- becomes nil
const test: string = "test";

-- number is available but in double form

float:lerp(a: float, b: float, float: float) {
	return a + (b - a) * c;
}

(nil):fragment() {
	-- Called for every pixel the material is visible on.
	
	dist: number = math.sqrt(math.pow(vec.X, 2) + math.pow(vec.Y, 2));
	
	COLOR = texture(TEXTURE, UV);
}

--> becomes luau formatted

local __d = require(script.env)
type PixelData = __d.PixelData
type float = __d.float
type vec2 = __d.vec2
type str = __d.str

--@!shader_type-canvas_item;

-- defining static variables
local world_uv: vec2; -- becomes nil
const test: str = "test";

function lerp(a: float, b: float, float: float): float
	return a + (b - a) * c;
end

function fragment(__p: PixelData): PixelData
	local dist: number = math.sqrt(math.pow(vec.X, 2) + math.pow(vec.Y, 2));
	
	__p.color = __d.read("texture", TEXTURE);
	
	return __p;
}

return fragment

]]



local a : Vector2