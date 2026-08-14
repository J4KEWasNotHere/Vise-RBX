--!strict
--[[
	Image Utility Module
	Adapted from photobooth project for pixel buffer manipulation
]]

local ImageStatic = {}

local ImageClass = {}
ImageClass.__index = ImageClass
ImageClass.ClassName = "Image"

export type Image = typeof(setmetatable(
	{} :: {
		buffer: buffer,
		size: Vector2,
		templateUri: string?,
	},
	ImageClass
))

-- Constructors

function ImageStatic.fromBuffer(buffer: buffer, size: Vector2)
	local self = setmetatable({} :: any, ImageClass) :: Image

	self.buffer = buffer
	self.size = size

	return self
end

function ImageStatic.fromSize(size: Vector2)
	return ImageStatic.fromBuffer(buffer.create(size.X * size.Y * 4), size)
end

function ImageStatic.fromEditableImage(editableImage: EditableImage, crop: Rect?)
	local fullSize = editableImage.Size
	local origin = if crop then crop.Min:Min(fullSize) else Vector2.zero
	local cropSize = if crop then (crop.Max - crop.Min):Min(fullSize) else fullSize

	local resultBuffer = editableImage:ReadPixelsBuffer(origin, cropSize)
	return ImageStatic.fromBuffer(resultBuffer, cropSize)
end

function ImageStatic.fromRGBA255(r: number, g: number, b: number, a: number, size: Vector2)
	local img = ImageStatic.fromBuffer(buffer.create(size.X * size.Y * 4), size)
	for x = 1, size.X do
		for y = 1, size.Y do
			local pixelIndex = img:GetPixelIndex(x, y)
			img:SetRGBA255(pixelIndex, r, g, b, a)
		end
	end
	return img
end

-- Public Methods

function ImageClass.Clone(self: Image)
	local copyBuffer = buffer.create(buffer.len(self.buffer))
	buffer.copy(copyBuffer, 0, self.buffer, 0)
	local copy = ImageStatic.fromBuffer(copyBuffer, self.size)
	copy.templateUri = self.templateUri
	return copy
end

function ImageClass.Crop(self: Image, rect: Rect)
	local size = rect.Max - rect.Min

	local clampedWidth = math.min(rect.Min.X + size.X, self.size.X) - rect.Min.X
	local clampedHeight = math.min(rect.Min.Y + size.Y, self.size.Y) - rect.Min.Y
	local targetBuffer = buffer.create(clampedWidth * clampedHeight * 4)

	for y = 1, clampedHeight do
		local sourceOffset = rect.Min.X + (rect.Min.Y + y - 1) * self.size.X
		local targetOffset = (y - 1) * clampedWidth
		buffer.copy(targetBuffer, targetOffset * 4, self.buffer, sourceOffset * 4, clampedWidth * 4)
	end

	return ImageStatic.fromBuffer(targetBuffer, Vector2.new(clampedWidth, clampedHeight))
end

function ImageClass.GetSize(self: Image)
	return self.size
end

function ImageClass.GetWidth(self: Image)
	return self.size.X
end

function ImageClass.GetHeight(self: Image)
	return self.size.Y
end

function ImageClass.GetPixelIndex(self: Image, x: number, y: number)
	return (x - 1) + (y - 1) * self.size.X
end

function ImageClass.GetRGBA255(self: Image, pixelIndex: number)
	local offset = pixelIndex * 4
	local r = buffer.readu8(self.buffer, offset)
	local g = buffer.readu8(self.buffer, offset + 1)
	local b = buffer.readu8(self.buffer, offset + 2)
	local a = buffer.readu8(self.buffer, offset + 3)
	return r, g, b, a
end

function ImageClass.SetRGBA255(
	self: Image,
	pixelIndex: number,
	r: number,
	g: number,
	b: number,
	a: number
)
	local offset = pixelIndex * 4
	buffer.writeu8(self.buffer, offset, r)
	buffer.writeu8(self.buffer, offset + 1, g)
	buffer.writeu8(self.buffer, offset + 2, b)
	buffer.writeu8(self.buffer, offset + 3, a)
end

function ImageClass.SetTemplateUri(self: Image, uri: string)
	self.templateUri = uri
end

return table.freeze(ImageStatic) :: typeof(ImageStatic)
