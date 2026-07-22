--[[
	Example Shader - Grayscale
	Simple shader that converts image to grayscale
]]

local GrayscaleShader = {}

function GrayscaleShader.apply(imageData)
	-- In a real implementation, this would process pixel data
	local result = imageData
	result.filter = "grayscale"
	result.applied_shader = "GrayscaleShader"
	return result
end

return GrayscaleShader
