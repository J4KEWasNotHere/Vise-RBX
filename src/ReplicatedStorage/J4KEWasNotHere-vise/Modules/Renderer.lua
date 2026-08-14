--[[
	Renderer Module
	Integrated from photobooth project
	Uses Future for async image rendering and CaptureService for real screenshots
]]

local AssetService = game:GetService("AssetService") :: AssetService
local CaptureService = game:GetService("CaptureService") :: CaptureService
local Future = require(script.Parent.Parent.Packages.Future)
local Renderer = {}

local function captureEditableImage()
	local contentUriFuture = Future.new()
	CaptureService:CaptureScreenshot(function(contentUri: string)
		contentUriFuture:complete(contentUri)
	end)

	local contentUri = contentUriFuture:expect()
	local editImage =
		AssetService:CreateEditableImageAsync(Content.fromUri(contentUri)) :: EditableImage

	return editImage, contentUri
end

function Renderer.captureImage(screenSize, position)
	local size = typeof(screenSize) == "Vector2" and screenSize or Vector2.new(256, 256)
	local capturePosition = typeof(position) == "Vector3" and position or Vector3.zero
	local future = Future.new()

	local success, editImage, contentUri = pcall(function()
		return captureEditableImage()
	end)

	if not success or editImage == nil then
		future:complete({
			size = size,
			position = capturePosition,
			timestamp = os.time(),
			source = "renderer.captureImage",
			error = "Failed to capture screenshot",
		})
		return future
	end

	future:complete({
		size = size,
		position = capturePosition,
		timestamp = os.time(),
		source = "renderer.captureImage",
		editableImage = editImage,
		contentUri = contentUri,
		viewportSize = workspace.CurrentCamera.ViewportSize,
	})
	return future
end

function Renderer.applyShader(imageData, shader)
	local future = Future.new()
	if not shader or not shader.apply then
		future:complete({
			error = "Invalid shader",
			data = imageData,
		})
		return future
	end

	local result = shader.apply(imageData)
	future:complete(result)
	return future
end

function Renderer.applyShaderChain(imageData, shaders)
	local result = imageData
	for _, shader in ipairs(shaders) do
		result = shader.apply(result)
	end
	return Future.completed(result)
end

return Renderer
