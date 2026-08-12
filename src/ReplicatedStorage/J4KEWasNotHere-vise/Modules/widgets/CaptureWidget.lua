local Constants = require("../external/Constants")
local Types = require("../external/Types")

local CaptureWidget = {}
CaptureWidget.__index = CaptureWidget

-- Services
local RunService = game:GetService("RunService")

-- Internal API

-- Plugin

function CaptureWidget:Bind(ctx: Types.ctx, toolbarButton, pluginRoot, pluginInstance)
	-- Setup
	local Computed = ctx.fusion.Computed
	local unwrap = ctx.fusion.unwrap
	local Value = ctx.fusion.Value
	local Children = ctx.fusion.Children
	local OnChange = ctx.fusion.OnChange
	local Observer = ctx.fusion.Observer

	local Label = ctx.components.Label
	local MainButton = ctx.components.MainButton
	local TextInput = ctx.components.TextInput
	local Checkbox = ctx.components.Checkbox
	local Seperator = ctx.components.Seperator
	local Loading = ctx.components.Loading
	local VerticalCollapsibleSection = ctx.components.VerticalCollapsibleSection
	local ScrollFrame = ctx.components.ScrollFrame
	local makeCard = ctx.ui.makeCard
	local makeSectionHeader = ctx.ui.makeSectionHeader

	local Widget = ctx.studio.Widget
	local AddWidget = ctx.studio.AddWidget

	-- State
	local widgetsEnabled = Value(false)

	-- Widget

	AddWidget({
		Name = `Capture | {Constants.NameId}`,

		Enabled = widgetsEnabled,
		InitialDockTo = Enum.InitialDockState.Float,
		FloatingSize = Vector2.new(400, 260),
		ScrollingEnabled = false,

		Children = { -- do not replace with [Children]
		},
	})

	toolbarButton.Click:Connect(function()
		widgetsEnabled:set(not widgetsEnabled:get())
	end)

	return function()
		widgetsEnabled:set(false)
	end
end

return CaptureWidget
