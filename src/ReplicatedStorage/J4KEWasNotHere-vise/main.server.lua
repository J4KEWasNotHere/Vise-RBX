--[[
	Vise - Icon Creator
	github.com/J4KEWasNotHere/Vise
	GPL-3.0 License
]]

-- Services
local RunService = game:GetService("RunService")

-- Setup

local pluginRoot = script.Parent
local toolbar = plugin:CreateToolbar("Vise")

-- Create toolbar buttons
local captureButton = toolbar:CreateButton("Capture", "Capture screenshot of the viewport.", "")
captureButton.ClickableWhenViewportHidden = false

local iconMakerButton = toolbar:CreateButton("Designer", "Edit your existing screenshots.", "")
iconMakerButton.ClickableWhenViewportHidden = true

local shaderEditButton = toolbar:CreateButton("Shaders", "Create a shader for vise.", "")
shaderEditButton.ClickableWhenViewportHidden = true

-- Resources
local Constants = require("./Modules/external/Constants")
local ctx = Constants._context

-- Variables
--local CaptureWidget = require("./Modules/widgets/CaptureWidget")

local ToBind = {
	{
		module = require("./Modules/widgets/CaptureWidget"),
		toolbar = captureButton,
	},
}

-- function Editor:performCapture()
-- 	print("[Vise] Capturing image...")
-- 	-- In a real plugin, this would capture the viewport
-- 	-- For now, create a dummy capture
-- 	local imageData = {
-- 		size = self.captureFrame:getSize(),
-- 		timestamp = os.time(),
-- 	}
-- 	self.project:createImage(imageData)
-- 	print("[Vise] Capture complete!")
-- end

-- Initialize
if RunService:IsStudio() and RunService:IsEdit() then
	for _, data in ipairs(ToBind) do
		data.module:Bind(ctx, data.toolbar, pluginRoot, plugin)
	end
end
