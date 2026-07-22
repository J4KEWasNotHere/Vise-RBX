--[[
	Vise - Lightweight Image Editor
	github.com/J4KEWasNotHere/Vise
	MIT License
]]

local pluginRoot = script.Parent
local toolbar = plugin:CreateToolbar("Vise")

-- Import core modules
local Project = require(pluginRoot.Modules.Project)
local Editor = require(pluginRoot.Modules.UI.Editor)

-- Create toolbar button
local captureButton = toolbar:CreateButton("Capture", "Capture screenshot", "")
captureButton.ClickableWhenViewportHidden = true

local editorInstance = nil

-- Handle capture button click
captureButton.Click:Connect(function()
	if not editorInstance then
		editorInstance = Editor.new(plugin, pluginRoot)
	end
	editorInstance:show()
end)
