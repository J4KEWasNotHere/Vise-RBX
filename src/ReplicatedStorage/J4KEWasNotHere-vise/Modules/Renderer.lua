--[[
	Renderer Module
	Uses Future for async image rendering and processing
]]

local Future = require(script.Parent.Parent.Packages.Future)
local Renderer = {}

function Renderer.captureImage(screenSize, position)
	-- Returns a Future that resolves with the captured image
	return Future.new(function(resolve, reject)
		-- Simulate capture - in real plugin this would use Studio's image capture API
		local imageData = {
			size = screenSize,
			position = position,
			timestamp = os.time(),
		}
		resolve(imageData)
	end)
end

function Renderer.applyShader(imageData, shader)
	-- Returns a Future for async shader application
	return Future.new(function(resolve, reject)
		if not shader or not shader.apply then
			reject("Invalid shader")
			return
		end
		local result = shader.apply(imageData)
		resolve(result)
	end)
end

function Renderer.applyShaderChain(imageData, shaders)
	-- Apply multiple shaders in sequence
	local future = Future.resolve(imageData)
	for _, shader in ipairs(shaders) do
		future = future:andThen(function(data)
			return Renderer.applyShader(data, shader)
		end)
	end
	return future
end

return Renderer
