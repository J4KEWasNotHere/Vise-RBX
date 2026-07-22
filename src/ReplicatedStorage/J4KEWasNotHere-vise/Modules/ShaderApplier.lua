--[[
	Shader Applier Module
	Applies shader modules to images
]]

local ShaderApplier = {}

function ShaderApplier.loadShader(modulePath)
	-- Load a shader module from the filesystem
	-- Module should export an apply(imageData) function
	local shader = require(modulePath)
	if not shader.apply or type(shader.apply) ~= "function" then
		error("Shader module must export an apply function")
	end
	return shader
end

function ShaderApplier.applyShader(imageData, shader)
	-- Apply a single shader
	return shader.apply(imageData)
end

function ShaderApplier.applyMultiple(imageData, shaders)
	-- Apply multiple shaders in sequence
	local result = imageData
	for _, shader in ipairs(shaders) do
		result = ShaderApplier.applyShader(result, shader)
	end
	return result
end

return ShaderApplier
