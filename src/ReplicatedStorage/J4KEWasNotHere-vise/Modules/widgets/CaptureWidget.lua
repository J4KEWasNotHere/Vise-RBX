local Constants = require("../external/Constants")

local CaptureWidget = {}
CaptureWidget.__index = CaptureWidget

-- Services
local HttpService = game:GetService("HttpService")

-- Internal API

-- Plugin

function CaptureWidget:Bind(ctx, toolbarButton, pluginRoot, pluginInstance)
	-- Setup
	local Value = ctx.fusion.Value
	local OnChange = ctx.fusion.OnChange
	local Children = ctx.fusion.Children
	local New = ctx.fusion.New

	local Widget = ctx.studio.Widget
	local AddWidget = ctx.studio.AddWidget

	local ScrollFrame = ctx.components.ScrollFrame

	-- State
	local widgetsEnabled = Value(false)

	return function()
		widgetsEnabled:set(false)
	end
end

return CaptureWidget
