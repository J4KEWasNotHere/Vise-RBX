--[[
	Shaders Registry
	Central registry for all available shaders
]]

local Shaders = {
	Grayscale = require("@self/Grayscale"),
	Blur = require("@self/Blur"),
}

return Shaders
