--[[
	Example Shader - Blur
	Simple shader that applies blur effect
]]

local BlurShader = {}

function BlurShader.apply(imageData)
	local result = imageData
	result.filter = "blur"
	result.applied_shader = "BlurShader"
	return result
end

return BlurShader
