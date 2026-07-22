--[[
	Project Manager
	Handles project save/load for captured images and their shader data
]]

local Project = {}
Project.__index = Project

function Project.new()
	local self = setmetatable({}, Project)
	self.images = {} -- {id = {data = imageData, shaders = {...}}}
	self.currentImage = nil
	return self
end

function Project:createImage(imageData)
	local id = #self.images + 1
	self.images[id] = {
		data = imageData,
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

function Project:addShader(shaderId, shaderModule)
	local image = self:getCurrentImage()
	if not image then
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
