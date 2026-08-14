--[[
	Project Manager
	Handles project save/load for captured images and their shader data
]]

local AssetService = game:GetService("AssetService") :: AssetService
local Image = require(script.Parent.Image)
local ShaderApplier = require(script.Parent.ShaderApplier)
local Project = {}
Project.__index = Project

local function computeCenteredCrop(fullSize: Vector2, wantSize: Vector2): Rect?
	if wantSize.X <= 0 or wantSize.Y <= 0 then
		return nil
	end

	-- Requested size covers (or exceeds) the full capture — no crop needed
	if wantSize.X >= fullSize.X and wantSize.Y >= fullSize.Y then
		return nil
	end

	local clampedWant = wantSize:Min(fullSize)
	local origin = Vector2.new(
		math.floor((fullSize.X - clampedWant.X) / 2),
		math.floor((fullSize.Y - clampedWant.Y) / 2)
	)

	return Rect.new(origin, origin + clampedWant)
end

function Project.new()
	local self = setmetatable({}, Project)
	self.images = {}
	self.currentImage = nil
	return self
end

function Project:createImage(imageData)
	local id = #self.images + 1

	local img = nil
	if imageData.editableImage then
		local fullSize = imageData.editableImage.Size
		local crop = imageData.size and computeCenteredCrop(fullSize, imageData.size) or nil

		img = Image.fromEditableImage(imageData.editableImage, crop)

		pcall(function()
			imageData.editableImage:Destroy()
		end)
		imageData.editableImage = nil
	end

	self.images[id] = {
		data = imageData,
		image = img,
		shaders = {},
		filters = {},
		timestamp = os.time(),
	}
	self.currentImage = id
	return id
end

function Project:getCurrentImage()
	if not self.currentImage then
		return nil
	end
	return self.images[self.currentImage]
end

function Project:_buildShadedImage()
	local image = self:getCurrentImage()
	if not image or not image.image then
		return nil
	end

	local result = image.image:Clone()

	for _, shaderEntry in ipairs(image.shaders) do
		local ok, shadedOrErr = pcall(ShaderApplier.applyShader, result, shaderEntry.module)
		if ok then
			result = shadedOrErr
		else
			warn(
				("Shader '%s' failed to apply: %s"):format(
					tostring(shaderEntry.id),
					tostring(shadedOrErr)
				)
			)
		end
	end

	return result
end

function Project:applyCurrentImageToWorkspace()
	local image = self:getCurrentImage()
	if not image then
		return nil
	end

	local shadedImage = self:_buildShadedImage()
	if not shadedImage then
		return nil
	end

	if shadedImage.size.X <= 0 or shadedImage.size.Y <= 0 then
		warn("Cannot render image with zero size")
		return nil
	end

	local editableImage = AssetService:CreateEditableImage({ Size = shadedImage.size })
	if not editableImage then
		return nil
	end
	editableImage:WritePixelsBuffer(Vector2.zero, shadedImage.size, shadedImage.buffer)

	local surface = workspace:FindFirstChild("ViseCapturePlane") or Instance.new("Part")
	surface.Name = "ViseCapturePlane"
	surface.Anchored = true
	surface.Material = Enum.Material.SmoothPlastic
	surface.Color = Color3.new(0, 0, 0)
	surface.Transparency = 1
	surface.Size =
		Vector3.new(math.max(1, shadedImage.size.X / 10), math.max(1, shadedImage.size.Y / 10), 0.2)
	surface.CFrame = (workspace.CurrentCamera and workspace.CurrentCamera.CFrame or CFrame.new())
		* CFrame.new(0, 0, -5)
	surface.Parent = workspace

	local surfaceGui = surface:FindFirstChild("ViseCaptureGui") :: SurfaceGui?
	if not surfaceGui then
		surfaceGui = Instance.new("SurfaceGui")
		surfaceGui.Name = "ViseCaptureGui"
		surfaceGui.Face = Enum.NormalId.Front
		surfaceGui.Parent = surface
	end

	local imageLabel = surfaceGui:FindFirstChild("ViseCaptureImage") :: ImageLabel?
	if not imageLabel then
		imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "ViseCaptureImage"
		imageLabel.BackgroundTransparency = 1
		imageLabel.Size = UDim2.fromScale(1, 1)
		imageLabel.Parent = surfaceGui
	end

	imageLabel.ImageContent = Content.fromObject(editableImage)

	if image.editableImage then
		pcall(function()
			image.editableImage:Destroy()
		end)
	end
	image.editableImage = editableImage

	return imageLabel
end

-- Load a shader module from a path and attach it to the current image
function Project:addShaderFromPath(shaderId, modulePath)
	local image = self:getCurrentImage()
	if not image then
		return
	end

	local ok, shaderOrErr = pcall(ShaderApplier.loadShader, modulePath)
	if not ok then
		warn(("Failed to load shader '%s': %s"):format(tostring(shaderId), tostring(shaderOrErr)))
		return
	end

	table.insert(image.shaders, {
		id = shaderId,
		module = shaderOrErr,
	})
end

-- Attach an already-required shader module directly
function Project:addShader(shaderId, shaderModule)
	local image = self:getCurrentImage()
	if not image then
		return
	end

	if not shaderModule or type(shaderModule.apply) ~= "function" then
		warn(("Shader '%s' does not export a valid apply function"):format(tostring(shaderId)))
		return
	end

	table.insert(image.shaders, {
		id = shaderId,
		module = shaderModule,
	})
end

function Project:clearShaders()
	local image = self:getCurrentImage()
	if not image then
		return
	end
	image.shaders = {}
end

function Project:saveProject()
	-- TODO: implement serialization
	return self
end

return Project
