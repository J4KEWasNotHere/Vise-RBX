--[[
	Vise - Icon Creator
	github.com/J4KEWasNotHere/Vise
	GPL-3.0 License
]]

-- Services
local Preloaded = game:GetService("Preloaded")
local RunService = game:GetService("RunService")

-- Setup

const pluginRoot = script.Parent
const toolbar = plugin:CreateToolbar("Vise")
local cleanedUp = false

-- Create toolbar buttons
const captureButton = toolbar:CreateButton("Capture", "Capture a screenshot of the viewport.", "")
captureButton.ClickableWhenViewportHidden = false

const iconMakerButton = toolbar:CreateButton("Designer", "Edit your existing Vise screenshots.", "")
iconMakerButton.ClickableWhenViewportHidden = true

const shaderEditButton = toolbar:CreateButton("Shaders", "Create shaders to use in Vise.", "")
shaderEditButton.ClickableWhenViewportHidden = true

-- Resources
local Constants = require("./Modules/external/Constants")
local ctx = Constants._context

-- Variables
const ToBind = {
	{
		module = require("./Modules/widgets/CaptureWidget"),
		cleanup = "",
		toolbar = captureButton,
	},
	{
		module = require("./Modules/widgets/DesignerWidget"),
		cleanup = "",
		toolbar = iconMakerButton,
	},
	{
		module = require("./Modules/widgets/ShaderWidget"),
		cleanup = "",
		toolbar = shaderEditButton,
	},
}

local Binded = {}

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

-- Utility

local function resolvePath(path, data)
	if typeof(data) ~= "table" then
		return data
	end

	local segments = string.split(path, "/")
	local current = data
	for _, segment in ipairs(segments) do
		if current[segment] then
			current = current[segment]
		else
			return nil
		end
	end
	return current
end

-- Functions

local function Cleanup()
	cleanedUp = true
	for _, data in ipairs(Binded) do
		data.cleanup()
	end

	print("--- CLEANED UP ---")
end

-- Initialize
plugin.Unloading:Connect(Cleanup)

if cleanedUp then
	return
end

print("--- STARTING PLUGIN ---")

if RunService:IsStudio() and RunService:IsEdit() then
	for i, data in ipairs(ToBind) do
		local bind = data.module:Bind(ctx, data.toolbar, pluginRoot, plugin)
		local cleanupFunc = data.cleanup == "" and bind or nil

		if not cleanupFunc then
			local func = resolvePath(data.cleanup, typeof(bind) == "function" and bind() or bind)
			if func and typeof(func) == "function" then
				cleanupFunc = func
			end

			continue -- if no cleanup is needed, just skip..
		end

		print(`Binded with cleanup at index {i}.`)

		Binded[i] = {
			bind = bind,
			cleanup = cleanupFunc,
		}
	end

	print("--- PLUGIN STARTED! --")
end
