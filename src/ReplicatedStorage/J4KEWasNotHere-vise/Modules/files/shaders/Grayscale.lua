--[[
	Example Shader - Grayscale
	Simple shader that converts image to grayscale
]]

local GrayscaleShader = {}

-- Standard luma weights (Rec. 601) — matches how most image tools compute
-- grayscale from RGB, weighting green heaviest since the eye is most
-- sensitive to it.
local R_WEIGHT = 0.299
local G_WEIGHT = 0.587
local B_WEIGHT = 0.114

function GrayscaleShader.apply(imageData)
	local result = imageData:Clone()

	local width = result:GetWidth()
	local height = result:GetHeight()

	for x = 1, width do
		for y = 1, height do
			local pixelIndex = result:GetPixelIndex(x, y)
			local r, g, b, a = result:GetRGBA255(pixelIndex)

			local luma = math.floor(r * R_WEIGHT + g * G_WEIGHT + b * B_WEIGHT + 0.5)
			luma = math.clamp(luma, 0, 255)

			result:SetRGBA255(pixelIndex, luma, luma, luma, a)
		end
	end

	return result
end

return GrayscaleShader
